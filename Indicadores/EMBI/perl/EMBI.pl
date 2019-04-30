#!/usr/bin/perl

use utf8;
use warnings;
use strict;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use WWW::Mechanize;


my $serie = 'http://www.ipeadata.gov.br/ExibeSerie.aspx?serid=40940&module=M';
my $html = get $serie;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tEMBI+ Brasil (Risco Brasil)";
  print LOG "\n\t\tlink utilizado: " . $serie;

if (getstore($serie, '../fonte/fonte_informacao_embi.html')) {
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $te = new HTML::TableExtract( keep_html=>0, depth => 1, count => 0 );
$te->parse($html);

my $sep = "|";  # separador
my $indice = "EMBI";
my @MATRIZ=();

foreach my $ts ($te->tables){
  foreach my $row ($ts->rows){

    if ($row->[1] =~ /\d+/) {

      my $data_dma =  $row->[0];
         $data_dma =~ s/\s+//g;
         $data_dma =~ s/\n|\r|\R|\r\n|&NBSP;//g;

      my $dia = substr($data_dma, 0, 2);
      my $mes = substr($data_dma, 3, 2);
      my $ano = substr($data_dma, 6, 4);

      my $data = $ano . "-" . $mes . "-" . $dia;

      my $valor =  $row->[1];
         $valor =~ s/\s+//g;
         $valor =~ s/\n|\r|\R|\r\n|&NBSP;//g;

         $valor =~ s/\.//g;

      push(@MATRIZ, $data . $sep . $indice . $sep . $valor . "\n");
    }
  }
}

# Exporta informações para arquivo 'pib', pronto para ser importado ao SQLite
my $saida = '../embi';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @MATRIZ;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/EMBI_Plus/embi)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$MATRIZ[0];
  print LOG   "\t\t\t".$MATRIZ[1];
  print LOG   "\t\t\t".$MATRIZ[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$MATRIZ[$#MATRIZ-2];
  print LOG   "\t\t\t".$MATRIZ[$#MATRIZ-1];
  print LOG   "\t\t\t".$MATRIZ[$#MATRIZ  ];
close(LOG);

