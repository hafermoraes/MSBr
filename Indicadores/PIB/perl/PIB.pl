#!/usr/bin/perl

use utf8;
use warnings;
use strict;

use Switch;
use LWP::Simple;
use HTML::TableExtract;
use WWW::Mechanize;


my $pagina_principal = 'http://www.ibge.gov.br/home/estatistica/indicadores/pib/defaulttabelas.shtm';
my $ibge_pib = url_atual($pagina_principal);
my $html = get $ibge_pib;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tPIB";
  print LOG "\n\t\tlink utilizado: " . $ibge_pib;

if (getstore($ibge_pib, '../fonte/fonte_informacao_pib.html')) {
  print LOG "\n\t\tdownload do html: OK";
} else {
  print LOG "\n\t\tdownload do html: Falhou";
}

my $te = new HTML::TableExtract( );
$te->parse($html);

my $sep = "|";  # separador
my $indice = "PIB";
my @PIB=();

foreach my $ts ($te->tables){
  foreach my $row ($ts->rows){

    if ($row->[0] =~ /\./) {

      my $mes = substr($row->[0], 0, 4) . periodo_para_mes_dia( substr( trim($row->[0]), 4 )  );

      my $valor = $row->[6];
      $valor =~ s/\s//g;
      $valor = $valor * 1e6;

      push(@PIB, $mes . $sep . $indice . $sep . $valor . "\n");
    }
  }
}

# Exporta informações para arquivo 'pib', pronto para ser importado ao SQLite
my $saida = '../pib';
open( FILE, ">$saida" ) || die "problema ao abrir $saida\n";
print FILE @PIB;
close(FILE);

  print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/PIB/pib)";
  print LOG "\n\t\tprimeiras 3 linhas:";
  print LOG "\n\t\t\t".$PIB[0];
  print LOG   "\t\t\t".$PIB[1];
  print LOG   "\t\t\t".$PIB[2];
  print LOG   "\t\túltimas 3 linhas:";
  print LOG "\n\t\t\t".$PIB[$#PIB-2];
  print LOG   "\t\t\t".$PIB[$#PIB-1];
  print LOG   "\t\t\t".$PIB[$#PIB  ];
close(LOG);

# ---------Funções
# acha link da tabela do mês mais recente
sub url_atual{
  my $mech = WWW::Mechanize->new();
  $mech->get( $_[0] );

  my @links = $mech->links();
  for my $link ( @links ) {
    #if ( $link->text =~ /(micas Trimestrais)/ ) {
    if ( $link->text =~ /( Correntes)/ ) {
      return "http://www.ibge.gov.br" . $link->url;
    }
  }
}

# trim: retira espaços da string
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

# mes: converte 'Jan' para '-01-01', etc...
sub periodo_para_mes_dia{
  switch($_[0]) {
    case ".I"   {return "-01-01"}
    case ".II"  {return "-03-01"}
    case ".III" {return "-09-01"}
    case ".IV"  {return "-12-01"}
  }
}
