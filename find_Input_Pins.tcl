# Write a TCL script that extracts some technology parameter from a 
# technology library. 
# More specifically, we would like to collect the input pin capacitance 
# for a subset of standard gates (defined by the user) whose description 
# is contained in the tech. 
# file CORE65LPSVT_bc_1.30V_m40C.lib. You can find the liberty file 
# in the /space/shared/sods-21/lab1_material folder of the remote machine. 
# Please, copy it in your working folder using the cp command.

# The data structure of the program is made up of the following two lists:
#   - User defined inputs
#       cell_ref_list: items are REFERENCE NAME of standard cells; 
#   - Outputs
#       pin_cap_list: items are list of input pin capacitances;
# Example:
# Suppose the cell_ref_list contains the following 3 standard cell names:
# cell_ref_list = {HS65_LS_IVX2} {HS65_LS_NAND2X2} {HS65_LS_NOR3X2} the pin capacitance list will contain:
# pin_cap_list = {{ 0.00093 } {0.000946 0.000914} {0.00137 0.001393 0.001272}}


# Set the path to the liberty file in your workspace
set fID [open {./CORE65LPSVT_bc_1.30V_m40C.lib} {r}]

# Input parameters
set cell_ref_list {HS65_LS_IVX2 HS65_LS_NAND2X2 HS65_LS_NOR3X2}

#empty list
set capList [list ]

set EOF [gets $fID line]

#consumed is 1 when the current line has been consumed (= analyzed) in the loop body

set state "CELL"

while { $EOF >= 0 } {

  if { $state eq "CELL" } {

    #declarationthe empty list for input pins' capacitances of actual port
    set tempList [list ]
     
    if { [regexp {\s*cell\(([A-Z0-9_]+)\)} $line matchVar name_cell] == 1} {
      
      if { [lsearch $cell_ref_list $name_cell ] > -1 } {
        #puts "Found the cell with name: $name_cell"
        set state "PIN"
      }
    }
  } elseif { $state eq "PIN" } {
     
     #if I'm in a new cell section
    if { [regexp {\s*cell\(([A-Z0-9_]+)\)} $line matchVar name_cell] == 1 } {
      set state "CELL"
      #puts $tempList
      lappend capList [list $tempList] 
    } else {

      if { [regexp {\s*pin\(([A-Z0-9_]+)\)} $line matchVar pin_name] == 1} {
        #puts "Found a pin with name: $pin_name"
        set state "CAP"
      }
    }
  } elseif { $state eq "CAP" } {

      if { [regexp {\s*capacitance : ([0-9]+\.?[0-9]*)} $line matchVar capacitance] == 1 } {
            
        set state "DIR"
      }



  } elseif { $state eq "DIR" } {

      if { [regexp {\s*direction : ([a-z]+);} $line matchVar direction] == 1 } {

        if { $direction eq "input" } {

          #puts "pin $pin_name: capacitance: $capacitance"
          lappend tempList $capacitance

        }
      }

      set state "PIN"
  }

  set EOF [gets $fID line]
}

puts "\n\nInput Pins Capacitances:"

for { set i 0 } { $i < [llength $cell_ref_list] } { incr i } {

  puts "[lindex $cell_ref_list $i] input pins capacitances:\t[lindex $capList $i]"

}
