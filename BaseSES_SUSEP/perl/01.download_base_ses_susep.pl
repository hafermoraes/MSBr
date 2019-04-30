#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use WWW::Mechanize;
use LWP::Simple;

# Escreve no LOG_Indicadores
  open( LOG, ">>../../LOG_BaseSES" ) || die "problema ao abrir log\n";
  print LOG "\n\tBase SES (Sistema de Estatísticas da SUSEP)";

my $base_ses = 'http://www2.susep.gov.br/menuestatistica/SES/principal.aspx';

my $mech = WWW::Mechanize->new();
$mech->get( $base_ses );

my $link_base_ses;

my @links = $mech->links();
for my $link ( @links ) {
  if ( $link->text =~ /Base de Dados do SES, atualizada a/ ) {
   $link_base_ses = $link->url;
  }
}

# Escreve no LOG Indicadores
print LOG "\n\t\tlink utilizado: " . $link_base_ses;
print $link_base_ses."\n";

if (getstore( $link_base_ses, '../fonte/fonte_base_ses.zip')){
  print LOG "\n\t\tdownload do ZIP: OK";
} else {
  print LOG "\n\t\tdownload do ZIP: Falhou";
}


close(LOG);
