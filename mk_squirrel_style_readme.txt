# To use the squirrel xml files with notepad++, follow these directions:


First, you must use the VS-2019-Dark theme.

Move 

VS-2019-Dark.xml 

into 

%appdata%\Notepad++\themes



Style configurator:

1. Open notepad++
2. From the menu nav located at top, select "Settings" -> "Style Configurator"
3. Select theme: VS2019-Dark
4. Make sure Foreground color is white and background color is black
5. MAKE SURE the "Enable global background colour"  or "Force background color for all styles" box is checked


Importing the language:

1. Click "Language" -> "User defined language" -> "Define your language"
2. Click "Import..." near the top left. 
3. Select "mk_squirrel_style.xml"  located in platform/scripts/ of R5Reloaded.
4. If you want to add .txt as an extention or .rson, you may do so next to "ext" where "nut gnut" are located. These are space separated extensions.

Reload:

1. Reload notepad++

Any .nut or .gnut files opened from this point forward will automatically apply the style.
If you have already opened files, thy will not automaically apply, however, you can click "Language" -> "Squirrel" on the file to manually apply the opened file.
