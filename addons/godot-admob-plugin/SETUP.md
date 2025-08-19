# Setup Instructions for Godot AdMob Plugin

## Step 1: Install the Plugin

1. Copy the entire `godot-admob-plugin` folder to your Godot project's `addons` directory:
   ```
   your-godot-project/
   ├── addons/
   │   └── godot-admob-plugin/
   │       ├── plugin.cfg
   │       ├── plugin.gd
   │       ├── AdMob.gd
   │       └── ...
   ```

2. Open your Godot project

3. Go to **Project → Project Settings → Plugins**

4. Find "Godot AdMob Plugin" in the list and click the "Enable" checkbox

5. The AdMob singleton should now be available globally

## Step 2: Verify Installation

After enabling the plugin, you can verify it's working by:

1. Creating a new script
2. Typing `AdMob.` and seeing if autocomplete shows the available methods

## Step 3: Test the Example

1. Open the example scene: `res://addons/godot-admob-plugin/example/AdMobDemo.tscn`
2. Run the scene
3. You should see test ads (Google provides test ads that always work)

## Troubleshooting

### "AdMob not declared" Error

If you get this error, it means the plugin isn't enabled:
- Check Project Settings → Plugins
- Make sure "Godot AdMob Plugin" is enabled
- Restart the Godot editor after enabling

### Plugin Not Showing in List

If the plugin doesn't appear:
- Verify the folder structure is correct (`addons/godot-admob-plugin/`)
- Check that `plugin.cfg` exists in the plugin folder
- Reload the project (Project → Reload Current Project)

### For Mobile Testing

The plugin only works on actual Android/iOS devices or emulators. In the Godot editor, you'll see a warning message instead of actual ads.