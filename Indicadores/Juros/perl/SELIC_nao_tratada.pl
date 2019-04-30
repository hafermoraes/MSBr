#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use LWP::Simple;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tJuros (Taxa SELIC)";

my $bacen_selic = 'http://www.bcb.gov.br/?COPOMJUROS';

  print LOG "\n\t\tlink utilizado: " . $bacen_selic;

my $html = get $bacen_selic;

if (getstore($bacen_selic, '../fonte/fonte_informacao_selic.html')) {
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $te = new HTML::TableExtract( );
$te->parse($html);

my $sep = "|";  # separador
my $indice = "SELIC";
my @SELIC;

foreach my $ts ($te->tables){
  foreach my $row ($ts->rows){
    #unless ( ($row->[5] =~ /\(/ ) ) {   # última coluna com conteúdo (5), observação...
      my $periodo_vigencia =  $row->[3];
         $periodo_vigencia =~ s/ \- /$sep/g; # susbtitui ' - ' por $sep

      my $valor;
      if ($row->[7] !~ /\d+,\d+/) {
        $valor =  $row->[4];
      } else {
        $valor = $row->[7];
      }
        $valor =~ s/,/./g;
        $valor =  $valor / 100;

      my $inicio = substr $periodo_vigencia, 0, 10;
      my $fim    = substr $periodo_vigencia, 11, 10;

      my $linha = formata_data($inicio) . $sep . formata_data($fim) . $sep . $indice . $sep . $valor . "\n";
      if ($row->[4] =~ /\d+,\d+/) {
        push(@SELIC, $linha) unless $row->[7] =~ /\(/;
      }
    #}
  }
}

# Exporta informações para arquivo 'selic', pronto para ser importado ao SQLite
my $saida = '../selic';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @SELIC;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/Juros/selic)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$SELIC[0];
  print LOG   "\t\t\t".$SELIC[1];
  print LOG   "\t\t\t".$SELIC[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$SELIC[$#SELIC-2];
  print LOG   "\t\t\t".$SELIC[$#SELIC-1];
  print LOG   "\t\t\t".$SELIC[$#SELIC  ];
close(LOG);

#------ Funções ---------
sub formata_data {
  my $fd_ano = substr $_[0], 6, 4;
  my $fd_mes = substr $_[0], 3, 2;
  my $fd_dia = substr $_[0], 0, 2;

  return $fd_ano . '-' . $fd_mes . '-' . $fd_dia;
}

