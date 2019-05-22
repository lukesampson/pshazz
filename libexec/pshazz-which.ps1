# Usage: pshazz which <name>
# Summary: Print the theme's path

param($name)

if (!$name) {
    my_usage
    exit 1
}

find_path $name
