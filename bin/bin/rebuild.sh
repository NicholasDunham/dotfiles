#!/bin/bash
set -e

# Get the profile to build (home, span, or hostname)
PROFILE=${1:-$(hostname)}

# Check for the update flag (supports both "update" and legacy "true")
PULL=${2:-false}

# Enable or disable specific modules
MODULE=${3:-""}
MODULE_ACTION=${4:-""}

# Convert common profile names to actual hostnames
case "$PROFILE" in
  home)
    HOST="ndunham-home-air"
    ;;
  span|work)
    HOST="ndunham-span-air"
    ;;
  *)
    HOST="$PROFILE"
    ;;
esac

echo "🔨 Rebuilding system: $HOST"

cd ~/.config/nix

# Handle module enabling/disabling
if [ -n "$MODULE" ] && [ -n "$MODULE_ACTION" ]; then
  if [ "$MODULE_ACTION" = "enable" ]; then
    echo "🔌 Enabling module: $MODULE"
    
    # Check for the module file
    if [ ! -f "./modules/$MODULE.nix" ]; then
      echo "❌ Error: Module $MODULE does not exist!"
      exit 1
    fi
    
    # Add to imports in the appropriate file
    case "$PROFILE" in
      home)
        # Check if already imported
        if ! grep -q "\.\.\/modules\/$MODULE\.nix" "./darwin/home.nix"; then
          sed -i '' '/imports = \[/a\
    ../modules/'"$MODULE"'.nix' "./darwin/home.nix"
          echo "📝 Added $MODULE to home configuration"
        else
          echo "ℹ️ Module $MODULE already enabled in home configuration"
        fi
        ;;
      span|work)
        # Check if already imported
        if ! grep -q "\.\.\/modules\/$MODULE\.nix" "./darwin/work.nix"; then
          sed -i '' '/imports = \[/a\
    ../modules/'"$MODULE"'.nix' "./darwin/work.nix"
          echo "📝 Added $MODULE to work configuration"
        else
          echo "ℹ️ Module $MODULE already enabled in work configuration"
        fi
        ;;
      *)
        # For any other host, add to default.nix
        if ! grep -q "\.\.\/modules\/$MODULE\.nix" "./darwin/default.nix"; then
          sed -i '' '/imports = \[/a\
    ../modules/'"$MODULE"'.nix' "./darwin/default.nix"
          echo "📝 Added $MODULE to default configuration"
        else
          echo "ℹ️ Module $MODULE already enabled in default configuration"
        fi
        ;;
    esac
    
    # Also ensure module is enabled in the configuration
    case "$PROFILE" in
      home)
        if ! grep -q "modules\.$MODULE\.enable = true" "./darwin/home.nix"; then
          sed -i '' '/modules = {/a\
    '"$MODULE"' = {\
      enable = true;\
    };' "./darwin/home.nix"
          echo "✅ Enabled $MODULE in home configuration"
        fi
        ;;
      span|work)
        if ! grep -q "modules\.$MODULE\.enable = true" "./darwin/work.nix"; then
          sed -i '' '/modules = {/a\
    '"$MODULE"' = {\
      enable = true;\
    };' "./darwin/work.nix"
          echo "✅ Enabled $MODULE in work configuration"
        fi
        ;;
      *)
        if ! grep -q "modules\.$MODULE\.enable = true" "./darwin/default.nix"; then
          # Add modules block if it doesn't exist
          if ! grep -q "modules = {" "./darwin/default.nix"; then
            sed -i '' '/imports = \[/a\\
  # Configure modules\
  modules = {\
    '"$MODULE"' = {\
      enable = true;\
    };\
  };' "./darwin/default.nix"
          else
            sed -i '' '/modules = {/a\
    '"$MODULE"' = {\
      enable = true;\
    };' "./darwin/default.nix"
          fi
          echo "✅ Enabled $MODULE in default configuration"
        fi
        ;;
    esac
    
  elif [ "$MODULE_ACTION" = "disable" ]; then
    echo "🔌 Disabling module: $MODULE"
    
    # Comment out the module in imports
    case "$PROFILE" in
      home)
        sed -i '' 's|^\([ ]*\)\(../modules/'"$MODULE"'.nix\)|#\1\2|' "./darwin/home.nix"
        # Set enable to false
        sed -i '' 's|\([ ]*\)'"$MODULE"'[ ]*=[ ]*{[ ]*enable[ ]*=[ ]*true|\1'"$MODULE"' = { enable = false|' "./darwin/home.nix"
        echo "📝 Disabled $MODULE in home configuration"
        ;;
      span|work)
        sed -i '' 's|^\([ ]*\)\(../modules/'"$MODULE"'.nix\)|#\1\2|' "./darwin/work.nix"
        # Set enable to false
        sed -i '' 's|\([ ]*\)'"$MODULE"'[ ]*=[ ]*{[ ]*enable[ ]*=[ ]*true|\1'"$MODULE"' = { enable = false|' "./darwin/work.nix"
        echo "📝 Disabled $MODULE in work configuration"
        ;;
      *)
        sed -i '' 's|^\([ ]*\)\(../modules/'"$MODULE"'.nix\)|#\1\2|' "./darwin/default.nix"
        # Set enable to false
        sed -i '' 's|\([ ]*\)'"$MODULE"'[ ]*=[ ]*{[ ]*enable[ ]*=[ ]*true|\1'"$MODULE"' = { enable = false|' "./darwin/default.nix"
        echo "📝 Disabled $MODULE in default configuration"
        ;;
    esac
  else
    echo "❌ Unknown module action: $MODULE_ACTION (use 'enable' or 'disable')"
    exit 1
  fi
fi

# Check for update flag (accept both "update" and legacy "true")
if [ "$PULL" = "update" ] || [ "$PULL" = "true" ]; then
  echo "⬇️  Pulling latest changes..."
  nix flake update
fi

echo "🏗️  Building configuration..."
nix build ".#darwinConfigurations.$HOST.system"

echo "🚀 Activating configuration..."
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$HOST"

echo "🧹 Cleaning up..."
rm -rf ./result

echo "✅ Done! System rebuilt successfully."