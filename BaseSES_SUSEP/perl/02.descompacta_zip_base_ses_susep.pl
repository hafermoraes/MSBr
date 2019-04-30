#!/use/bin/perl

use strict;
use utf8;
use warnings;

use Archive::Extract;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../LOG_BaseSES" ) || die "problema ao abrir log\n";

# unzip
my $input  = "../fonte/fonte_base_ses.zip";
my $output = "../fonte/CSVs";

my $ae = Archive::Extract->new( archive => $input );
if ( $ae->extract( to => $output ) ){
  print LOG "\n\t\tunzip dos CSVs: OK";
} else {
  print LOG "\n\t\tunzip dos CSVs: Falhou";
}

close(LOG);