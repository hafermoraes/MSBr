#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use WWW::Mechanize;
use LWP::Simple;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
  print LOG "\n\tDívida Pública";

my $bcb_divida = 'http://www.bcb.gov.br/?DIVIDADLSP';

my $mech = WWW::Mechanize->new();
$mech->get( $bcb_divida );

my $link_divida;

my @links = $mech->links();
for my $link ( @links ) {
  if ( $link->text =~ /ZIP/ ) {
   $link_divida = "http://www.bcb.gov.br" . $link->url;
  }
}

# Escreve no LOG Indicadores
print LOG "\n\t\tlink utilizado: " . $link_divida;

if (getstore( $link_divida, '../fonte/fonte_divida_publica.zip')){
  print LOG "\n\t\tdownload do ZIP: OK";
} else {
  print LOG "\n\t\tdownload do ZIP: Falhou";
}


close(LOG);
