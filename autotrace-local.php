<?php

// Copyright 2005 Rob Myers <rob@robmyers.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
/////////////////////////////////////////////////////////////////////////////// 
// Functions
///////////////////////////////////////////////////////////////////////////////

// Autotrace image to SVG (autotrace).
// Posterises image as well (don't need to use Imagemagick).

function autotrace ($colour_count, $filename) 
{
  global $current_id;
  $filename_tga = preg_replace ("/.jpg$/", ".tga", $filename);
  $convert_command = "djpeg -targa " . $filename . " > " . $filename_tga;
  $result = 0;
  exec ($convert_command, $result);
  /*// Always fails???
    if ($result != 0)
    {
      return $result;
      }*/
  $filename_svg = preg_replace ("/.jpg$/", ".svg", $filename);
  $autotrace_command = "autotrace -color-count " . $colour_count .
    " -despeckle-level 5 -input-format tga " .
    "-output-file " . $filename_svg . " " . $filename_tga;
  exec ($autotrace_command, $result);
  @unlink ($filename_tga);
  return $result;
}

?>
