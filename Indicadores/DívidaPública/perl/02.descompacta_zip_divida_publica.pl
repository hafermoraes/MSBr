#!/use/bin/perl

use strict;
use utf8;
use warnings;

use IO::Uncompress::Unzip qw(unzip $UnzipError);

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";

  my $input  = "../fonte/fonte_divida_publica.zip";
my $output = "../fonte/fonte_divida_publica.xls";

if (unzip $input => $output, Name => "Divggp.xls") {
  print LOG "\n\t\tunzip para o arquivo excel: OK";
} else {
  print LOG "\n\t\tunzip para o arquivo excel: falhou";
}

close(LOG);



#unzip $input => $output, Name => "Divggp.xls"
  # or die "erro ao descompactar: $UnzipError\n";