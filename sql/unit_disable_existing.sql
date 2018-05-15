# For any question about this script, ask Franck
#
# Pre-requisite:
#	- The unit must already exists in the BZ table
#
# This script will 
#	- Disable the unit
#	- Log what it does in the BZ database
#	- Exit with no error if everything went as expected
#
#################################################################
#
# UPDATE THE BELOW VARIABLES ACCORDING TO YOUR NEEDS
#
#################################################################

# We need the BZ product id for the unit
	SET @product_id = 'bz_product_id_of_unit_to_disable';

# We also need to know the date when the unit was disabled in the MEFE
	SET @inactive_when = 'datetime_when_the_unit_was_disabled_in_the_MEFE';
	
#
########################################################################
#
# ALL THE VARIABLES WE NEED HAVE BEEN DEFINED, WE CAN RUN THE SCRIPT 
#
########################################################################
	
# We have everything, we can now call the procedure which disables a unit
	CALL `unit_disable_existing`;
	
