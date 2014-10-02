while (<>) {
	if (/^FILEVERSION\s+(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/) {
		print "$1.$2.$3.$4";
		last;
	}
}