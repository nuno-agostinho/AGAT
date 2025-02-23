#!/usr/bin/env perl

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use AGAT::Omniscient;
use Bio::Tools::GFF;

my $header = get_agat_header();
my $start_run = time();
my $opt_gfffile;
my $opt_comonTag=undef;
my $opt_verbose=undef;
my $opt_deep=undef;
my $opt_output;
my $opt_help = 0;

# OPTION MANAGMENT
if ( !GetOptions( 'g|gff=s'     => \$opt_gfffile,
                  'c|ct=s'      => \$opt_comonTag,
                  'v'           => \$opt_verbose,
                  'd'           => \$opt_deep,
                  'o|output=s'  => \$opt_output,
                  'h|help!'     => \$opt_help ) )
{
    pod2usage( { -message => 'Failed to parse command line',
                 -verbose => 1,
                 -exitval => 1 } );
}

# Print Help and exit
if ($opt_help) {
    pod2usage( { -verbose => 99,
                 -exitval => 0,
                 -message => "$header\n" } );
}

if (! defined($opt_gfffile) ){
    pod2usage( {
           -message => "$header\nAt least 1 parameter is mandatory:\nInput reference gff file (-g).\n\n".
           "Ouptut is optional. Look at the help documentation to know more.\n",
           -verbose => 0,
           -exitval => 1 } );
}

######################
# Manage output file #

my $gffout;
if ($opt_output) {
  $opt_output=~ s/.gff//g;
  open(my $fh, '>', $opt_output.".gff") or die "Could not open file '$opt_output' $!";
  $gffout= Bio::Tools::GFF->new(-fh => $fh, -gff_version => 3 );
  }
else{
  $gffout = Bio::Tools::GFF->new(-fh => \*STDOUT, -gff_version => 3);
}

                #####################
                #     MAIN          #
                #####################

######################
### Parse GFF input #
if($opt_verbose and $opt_deep) {$opt_verbose = 2 ;}
my ($hash_omniscient, $hash_mRNAGeneLink) =  slurp_gff3_file_JD({
                                                               input => $opt_gfffile,
                                                               locus_tag => $opt_comonTag,
                                                               verbose => $opt_verbose
                                                               });
print ("GFF3 file parsed\n");

###
# Print result
print_omniscient_as_match( {omniscient => $hash_omniscient, output => $gffout} ); 

my $end_run = time();
my $run_time = $end_run - $start_run;
print "Job done in $run_time seconds\n";
__END__

=head1 NAME

agat_sp_alignment_output_style.pl

=head1 DESCRIPTION

The script takes a normal gtf/gff annotation format file and convert it
to gff3 alignment format. It means it add a structure of match / match_part
as relationship between the different features.

=head1 SYNOPSIS

    agat_sp_alignment_output_style.pl -g infile.gff [ -o outfile ]
    agat_sp_alignment_output_style.pl --help

=head1 OPTIONS

=over 8

=item B<-g>, B<--gff> or B<-ref>

Input GTF/GFF file.

=item B<-c> or B<--ct>

When the gff file provided is not correcly formated and features are linked
to each other by a comon tag (by default locus_tag), this tag can be provided
to parse the file correctly.

=item B<-v>

Verbose option to see the warning messages when parsing the gff file.

=item B<-o> or B<--output>

Output GFF file.  If no output file is specified, the output will be
written to STDOUT.

=item B<-h> or B<--help>

Display this helpful text.

=back

=head1 FEEDBACK

=head2 Did you find a bug?

Do not hesitate to report bugs to help us keep track of the bugs and their
resolution. Please use the GitHub issue tracking system available at this
address:

            https://github.com/NBISweden/AGAT/issues

 Ensure that the bug was not already reported by searching under Issues.
 If you're unable to find an (open) issue addressing the problem, open a new one.
 Try as much as possible to include in the issue when relevant:
 - a clear description,
 - as much relevant information as possible,
 - the command used,
 - a data sample,
 - an explanation of the expected behaviour that is not occurring.

=head2 Do you want to contribute?

You are very welcome, visit this address for the Contributing guidelines:
https://github.com/NBISweden/AGAT/blob/master/CONTRIBUTING.md

=cut

AUTHOR - Jacques Dainat
