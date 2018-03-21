#!perl -w
use strict;
use Path::Tiny;
my $filename = shift or die "Usage: $0 FILENAME [-d debug mode]";
my $debug = shift;
my $fh = path($filename)->edit_utf8( \&delimit);
  # $fh->edit_utf8( \&delimit_where_date );
no warnings 'uninitialized';
sub delimit {
  s/((\b\w{4})([.,-·\s])?$)|(\-\-\s*)$/$1¥\n/gm unless /¥/;
}

print $debug," mode\n----------\n" if $debug;

binmode STDOUT, ":utf8";
$fh = path($filename)->openr_utf8;
#no warnings 'uninitialized';
my ( $running_title, $running_location );
while (
    defined(
        my $record =
          do { local $/ = '¥'; <$fh> }
    )
  )
{
    $record = cleanup($record);
    print "\nOriginal record $. -> $record" if $debug;
    if ( my ($embolded_title_prefix) =
        $record =~ m/\A\s*([\p{Uppercase_Letter}]{3,})/ )
    { # e.g. ABÆLARDI from a title like ABÆLARDI Filosophi et Theologi Abates...
        $running_title = $embolded_title_prefix
          if defined($embolded_title_prefix);
        $record =~ s/  \A(?<title>([^\d]+)?)   //mxs
          and handle_title( $+{title} );
    }
    else {
        $record =~
          s/  \A(?<title>([^\d]+)?)   //mxs;    
        handle_title( $+{title}, $running_title );
    }
    $record =~ s/  (?<volume>[\d{1,}|is].{1}\bv[oe0][l]).+? //mxs
      and handle_volume( $+{volume} );
    $record =~ s/  (?<format>[\ds-]+[mvt']+.)  //mxs
      and handle_format( $+{format} );
    $record =~ s/  (?<location>[\w]+)\b\W*[,.\s]+ //mxs
      and handle_location( $+{location} );
    $record =~ s/  (?<year>\w{3,4})¥\s*\z/$1/mxs and handle_year( $+{year} );
}

sub handle_title {
    my ( $title, $title_prefix ) = @_;
    $title = trim($title);
    $title =~ s/\A[^\w]+(\w+.*)\z/$1/;
    if ( defined($title_prefix) ) {
        if ($debug) {print "\nParsed record -> Title:[$title_prefix... $title]\t" } else {
          print $title_prefix,"... $title\t";
        }
    }
    else {
        if ($debug) {print "\nParsed record -> Title:[$title]\t"} else { print $title,"\t" }
        
    return;
    }
 }


sub handle_volume {
    my $volume = shift;
    $volume = trim($volume);
    if ($debug) { print "Volume:[$volume]\t"} else {print $volume,"\t"}
    return;
}

sub handle_format {
    my $format = shift;
    $format = trim($format);
    if ($debug) {print "Format:[$format]\t"} else {print $format, "\t"}
    return;
}

sub handle_location {
    my ($location) = @_;
    if ( defined $location and trim($location) !~ m/ditto/ ) {
        $running_location = $location;
        if ($debug) { print "Location:[$location]\t"} else {print $location, "\t"}
    }
    else {
        if ($debug) { print "Location:[$running_location]\t"} else {print $running_location,"\t"}
    }
    return;
}

sub handle_year {
    my $year = shift;
    $year = trim($year);
    if ($debug) { print "Year:[$year]\n\n-----------------------------\n"} else {print $year,"\n"} 
    return;
}

sub trim {
    my @out = @_;
    for (@out) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @out : $out[0];
}

sub cleanup {
    my $record = shift;
    $record =~ s/[|\n\r\f]//gsm;
    $record =~ s/\s{2,}/ /gsm;
    $record =~ s/\s{2,}/ /gsm;
    $record =~ s/i vol\./1 vol./;
    $record =~ s/s vol\./5 vol./;
    $record =~ s/\bSvo\./5vo/m;
    $record =~ s/\t/ /gsm;
    return $record;
}
