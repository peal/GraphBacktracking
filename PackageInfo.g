#
# GraphBacktracking: Super Secret Awesome Searching
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "GraphBacktracking",
Subtitle := "Super Secret Awesome Searching",
Version := "0.1",
Date := "06/12/2018", # dd/mm/yyyy format

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Christopher",
    LastName := "Jefferson",
    WWWHome := "http://caj.host.cs.st-andrews.ac.uk/",
    Email := "caj21@st-andrews.ac.uk",
    PostalAddress := Concatenation(
               "St Andrews\n",
               "Scotland\n",
               "UK" ),
    Place := "St Andrews",
    Institution := "University of St Andrews",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Markus",
    LastName := "Pfeiffer",
    WWWHome := "http://www.morphism.de/~markusp/",
    Email := "markus.pfeiffer@morphism.de",
    PostalAddress := Concatenation(
               "School of Computer Science\n",
               "University of St Andrews\n",
               "Jack Cole Building, North Haugh\n",
               "St Andrews, Fife, KY16 9SX\n",
               "United Kingdom" ),
    Place := "St Andrews",
    Institution := "University of St Andrews",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Wilf",
    LastName := "Wilson",
    WWWHome := "http://wilf.me",
    Email := "gap@wilf-wilson.net",
    PostalAddress := Concatenation(["Theodor-Lieser-Straße 5, ",
                                    "06120 Halle (Saale), ",
                                    "Germany"]),
    Place := "Halle (Saale), Germany",
    Institution := "University of Halle-Wittenberg",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := false,
    FirstNames := "Mun See",
    LastName := "Chang",
    #WWWHome := TODO,
    Email := "msc2@st-andrews.ac.uk",
    PostalAddress := "School of Computer Science, North Haugh, St Andrews, Fife, KY16 9SX, Scotland",
    Place := "St Andrews",
    Institution := "University of St Andrews",
  ),
],

SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/ChrisJefferson/GraphBacktracking",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://ChrisJefferson.github.io/GraphBacktracking/",
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "GraphBacktracking",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Super Secret Awesome Searching",
),

Dependencies := rec(
  GAP := ">= 4.9",
  NeededOtherPackages := [ ["BacktrackKit", ">= 0.1",], ["digraphs", ">= 0.2.2"], ["OrbitalGraphs", ">= 0.1"] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));


