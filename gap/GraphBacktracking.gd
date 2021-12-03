#
# GraphBacktracking
#
# Implementations
#

DeclareGlobalFunction( "GB_SimpleSearch" );

DeclareGlobalFunction( "GB_SimpleSinglePermSearch" );

DeclareGlobalFunction( "GB_SimpleAllPermSearch" );

DeclareGlobalFunction( "GB_CheckInitialGroup" );
DeclareGlobalFunction( "GB_CheckInitialCoset" );

#! @Description
#!  Information about backtrack search
InfoGB := InfoBTKit;

# Merge infos
#DeclareInfoClass( "InfoGB" );
#SetInfoLevel(InfoGB, 0);
