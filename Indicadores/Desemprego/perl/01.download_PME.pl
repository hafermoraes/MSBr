#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use WWW::Mechanize;
use LWP::Simple;

my $html = 'http://www.ibge.gov.br/home/estatistica/indicadores/trabalhoerendimento/pme_nova/defaulttab_hist.shtm';

my $mech = WWW::Mechanize->new();
$mech->get( $html );

# Encontra o link atual na página $html
my $link_atual;
my @links = $mech->links();
for my $link ( @links ) {
    if ( $link->url =~ /tab177/ ) {
      $link_atual =  $link->url;
    }
  }

# Escreve no LOG_Indicadores
  my $saida = '../../../LOG_Indicadores';
  open( LOG, ">>$saida" ) || die "problema ao abrir $saida\n";
  print LOG "\n\tDesemprego\n\t\tlink utilizado: ".$link_atual;

  if ( getstore($link_atual, '../fonte/fonte_PME.xls') ) {
    print LOG "\n\t\tdownload do xls: OK";
  } else {
    print LOG "\n\t\tdownload do xls: Falhou";
  }

  close(LOG);
