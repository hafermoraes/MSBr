#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use WWW::Mechanize;

my $ibge_ipca = 'http://www.ibge.gov.br/home/estatistica/indicadores/precos/inpc_ipca/defaulttab.shtm';
my $url_atual = url_atual($ibge_ipca);
my $html = get $url_atual;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tInflação (IPCA)";
  print LOG "\n\t\tlink utilizado: " . $url_atual;

if (getstore($url_atual, '../fonte/fonte_informacao_ipca.html')){
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $te = new HTML::TableExtract( keep_html=>0, depth => 0, count => 3 );
$te->parse($html);

my $sep = "|";  # separador
my $ano;
my $mes_dia;
my $valor;
my $NoMes;
my $indice = "IPCA";
my @IPCA = ();

foreach my $ts ($te->tables){
  foreach my $row ($ts->rows){

    $mes_dia = $row->[1];
    $mes_dia =~ s/\s+//g;
    $mes_dia =~ s/\n|\r|\R|\r\n|&NBSP;//g;

    # correção necessária para arrumar formatação da página.
    # se $mes_dia é nulo, descola o vetor em uma casa para a direita
    my $j = 0;
    if ($mes_dia eq '') {
       $j = 1;

       $mes_dia = $row->[1 + $j];
       $mes_dia =~ s/\s+//g;
       $mes_dia =~ s/\n|\r|\R|\r\n|&NBSP;//g;
    }

    if ( ($mes_dia ne 'Mês') && ( $mes_dia ne '' ) ){

      # ano
      my $ano_aux = $row->[0 + $j];
      if ( $ano_aux =~ m/\d+/g) {
        $ano = $ano_aux;
        $ano =~ s/\s+//g;
        $ano =~ s/\n|\r|\R//g;
      }

      # valor
      $valor = trim( $row->[7 + $j] );
      $valor =~ s/\,/\./g;
      $valor = $valor / 100;

      $NoMes = $row->[3 + $j];
      if ( ($NoMes =~ m/\d+/g) && ($NoMes ne '') ){
        push(@IPCA, $ano . mes(trim( $row->[1 + $j] ) ) . $sep . $indice . $sep . $valor . "\n");
      }
    }
  }
}

# Exporta informações para arquivo 'ipca', pronto para ser importado ao SQLite
my $saida = '../ipca';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @IPCA;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/Inflação/ipca)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$IPCA[0];
  print LOG   "\t\t\t".$IPCA[1];
  print LOG   "\t\t\t".$IPCA[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$IPCA[$#IPCA-2];
  print LOG   "\t\t\t".$IPCA[$#IPCA-1];
  print LOG   "\t\t\t".$IPCA[$#IPCA  ];

close(LOG);
# ---------Funções
# acha link da tabela do mês mais recente
sub url_atual{
  my $mech = WWW::Mechanize->new();
  $mech->get( $_[0] );

  my @links = $mech->links();
  for my $link ( @links ) {
    if ( $link->text =~ /\-IPCA\/INPC/ ) {
      return "http://www.ibge.gov.br" . $link->url;
    }
  }
}

# trim: retira espaços da string
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

# mes: converte 'Jan' para '-01-01', etc...
sub mes{
  switch($_[0]) {
    case "Jan" {return "-01-01"}
    case "Fev" {return "-02-01"}
    case "Mar" {return "-03-01"}
    case "Abr" {return "-04-01"}
    case "Mai" {return "-05-01"}
    case "Jun" {return "-06-01"}
    case "Jul" {return "-07-01"}
    case "Ago" {return "-08-01"}
    case "Set" {return "-09-01"}
    case "Out" {return "-10-01"}
    case "Nov" {return "-11-01"}
    case "Dez" {return "-12-01"}

  }
}
