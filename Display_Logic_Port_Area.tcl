# Write a TCL script (to be run in tclsh) that extracts from a tech. library (the CORE65LPSVT_bc_1.30V_m40C.lib) a specified parameter of a given set of std. cells. The data structure of the program can be arranged as follows:
#    - User defined inputs:
#        cell_list: items are REFERENCE NAME of standard cells
#        tech_par: which contains the name of the tech. parameter to be extracted; 
#                  available options are area, leakage (cell leakage power), rise (worst case rise time at the output pin Z), 
#                  fall (worst case fall time at the output pin Z);
#
#    - output_list: contains, for each cell, the value of the selected parameter.


# Set the path to the liberty file in your workspace
set fID [open {./CORE65LPSVT_bc_1.30V_m40C.lib} {r}]

# Input parameters
set cell_ref_list {HS65_LS_IVX2 HS65_LS_NAND2X2 HS65_LS_NOR3X2}
set tech_par "area"
set EOF [gets $fID line]

set state "CELL"

#output
set paramList [list ]

while { $EOF >= 0 } {

	if { $state eq "CELL" } {

		if { [regexp {\s?cell\(([A-Z0-9_]+)\)} $line matchVar cellName] > 0 } {

			if { [lsearch $cell_ref_list $cellName] > -1 } {

				
				set state "PARAM"

			}
		}

	} elseif { $state eq "PARAM" } {

		if { [regexp {\s*([a-z]+) : ([0-9]+\.?[0-9]*)} $line matchVar paramLabel value] } {

			if { $paramLabel eq $tech_par } {

				lappend paramList $value
				set state "CELL"
			}
		}
		if { [regexp {\s?cell\(([A-Z]+)\)} $line matchVar cellName] } {

			set state "CELL"
		}

	}

	set EOF [gets $fID line]
}	

for {set i 0} {$i < [llength $cell_ref_list] } {incr i} {

	puts "[lindex $cell_ref_list $i] $tech_par:\t[lindex $paramList $i]"
}