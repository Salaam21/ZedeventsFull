ICON generation and placement instructions

Place the provided ZedEvents logo image in this folder and run the commands below to prepare launcher icons.

Filename suggestions (used by `pubspec.yaml`):
- assets/images/app_icon.png
- assets/images/app_icon_foreground.png
- assets/images/app_icon_background.png

If you only have a single image (recommended: 1024x1024 PNG), you can use the same file for all three. Example Powershell copy:

```powershell
# Assuming the downloaded logo is at $PWD\zedevents_logo.png
Copy-Item .\zedevents_logo.png .\app_icon.png -Force
Copy-Item .\zedevents_logo.png .\app_icon_foreground.png -Force
Copy-Item .\zedevents_logo.png .\app_icon_background.png -Force
```

Recommended (better) workflow using ImageMagick to create a transparent foreground and a solid background:

```powershell
# Install ImageMagick first (if not installed): https://imagemagick.org
# Create a square 1024x1024 canvas (foreground with transparency)
magick convert zedevents_logo.png -resize 1024x1024 -background none -gravity center -extent 1024x1024 app_icon_foreground.png
# Create a background (solid color) from the same image or a chosen color
magick convert zedevents_logo.png -resize 1024x1024 -gravity center -extent 1024x1024 -background "#FFFFFF" -flatten app_icon_background.png
# Also create the fallback full icon
magick convert zedevents_logo.png -resize 1024x1024 app_icon.png
```

After the files exist in this folder, generate launcher icons with:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

Notes:
- The single-file approach (copying the same image to all three names) works and is the simplest.
- For best quality on Android adaptive icons, provide a transparent foreground and a simple background image or solid color.
- If you want me to generate simple foreground/background images from the attached logo, tell me and I'll create basic files (foreground with trimmed transparent background + solid white background) in this folder.
