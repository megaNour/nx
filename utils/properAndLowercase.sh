#!/bin/sh

# Convert input to proper case and lowercase on two output lines per input line
# Example: "fiLe" -> first line: "File", second line: "file"
properAndLowercase() {
  awk '{
    print toupper(substr($0,1,1)) tolower(substr($0,2))
    print tolower($0)
  }'
}
