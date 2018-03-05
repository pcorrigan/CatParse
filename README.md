# Catalogue Parser

Parse a poor OCR copy of an early an 19th century catalogue. Identify Title, Volumes, Format, Place of Publication and Date of Publication.
The parser requires the sample data file data.txt be preprocessed to delimit it into yen symbol delimited records:
The following one liner does this: 
	perl -pi.bak -e 's/(\d{4}|[\d\w]+?)[.,-·\s]$/$1¥\n/' data.txt
