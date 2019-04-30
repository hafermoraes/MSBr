#!/usr/bin/perl

use utf8;
use warnings;
use strict;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use WWW::Mechanize;


my $reservas_USD = 'https://www3.bcb.gov.br/sgspub/consultarvalores/consultarValoresSeries.do?method=consultarSeries&series=13621';
my $html = get $reservas_USD;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tReservas Internacionais em USD";
  print LOG "\n\t\tlink utilizado: " . $reservas_USD;

if (getstore($reservas_USD, '../fonte/fonte_informacao_reservas_USD.html')) {
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $te = new HTML::TableExtract( keep_html=>0, depth => 0, count => 4 );
$te->parse($html);

my $sep = "|";  # separador
my $indice = "Reservas_Intl_USD";
my @RESERVAS=();

foreach my $ts ($te->tables){
  foreach my $row ($ts->rows){

    if ($row->[1] =~ /\./) {

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
         $valor = $valor * 1e6;

      push(@RESERVAS, $data . $sep . $indice . $sep . $valor . "\n");
    }
  }
}

# Exporta informações para arquivo 'pib', pronto para ser importado ao SQLite
my $saida = '../ReservasUSD';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @RESERVAS;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/ReservasUSD/reservas_USD)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$RESERVAS[0];
  print LOG   "\t\t\t".$RESERVAS[1];
  print LOG   "\t\t\t".$RESERVAS[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$RESERVAS[$#RESERVAS-2];
  print LOG   "\t\t\t".$RESERVAS[$#RESERVAS-1];
  print LOG   "\t\t\t".$RESERVAS[$#RESERVAS  ];
close(LOG);

