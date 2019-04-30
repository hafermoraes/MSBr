#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use Encode;
binmode STDOUT, ':encoding(utf-8)';

use HTML::TableExtract;

# Escreve no LOG_Indicadores
open( LOG, ">>../../../LOG_Indicadores" ) || die "problema ao abrir log\n";
print LOG "\n\tSUSEP - Mercado Supervisionado";

# cria o navegador
use WWW::Mechanize;
use LWP::Simple;
my $browser = WWW::Mechanize->new();

# acessa a página com o navegador
my $url = "http://www2.susep.gov.br/menuatendimento/procura_2011.asp";
$browser->get($url);

# hash para os tipos de empresa
my %tipo_empresa = (
      "5" => 'Autorreguladoras'        ,
      "6" => 'Capitalização'           ,
      "8" => 'Corretores_de_Resseguro' ,
      "1" => 'Previdência'             ,
      "4" => 'Resseguradora_Admitida'  ,
      "7" => 'Resseguradora_Eventual'  ,
      "3" => 'Resseguradora_Local'     ,
      "2" => 'Seguradoras'             ,
   );

# 'Mercado_Supervisionado' guardará a lista de todo o mercado supervisionado,
# pronta para ser importada ao SQLite
my $output = '../Mercado_Supervisionado';
open( FILE, ">$output" ) || die "problema ao abrir $output\n";
  print FILE 'Nome|CNPJ|Código.FIP|Endereço|Cidade|Cep|DDD|Telefone|Fax|Data.Autorizacao|Tipo.Empresa';
close(FILE);

my @susep_lista;
foreach my $codigo_empresa ( keys %tipo_empresa) {
    # Escreve no LOG_Indicadores
    print LOG "\n\t\t$tipo_empresa{$codigo_empresa}: OK";

    # preenche campo 'Escolha o Tipo de Empresa:'
                $browser->form_number(1);
                $browser->field("tiposempresas", $codigo_empresa);
                $browser->click();
    my $saida = $browser->content();

    # salva página fisicamente no diretorio ../fonte/
     open( my $fh, '>', '../fonte/'. $tipo_empresa{ $codigo_empresa } .'.html' );
     print $fh $saida;
     close $fh;

    # restringe a string para a tabela de interesse
     my $corte = index ( $saida, "encontrada(s):");
        $saida = substr( $saida, $corte );

    # Parse no HTML e guarda as informações no vetor @auxiliar
    my $te = new HTML::TableExtract();
       $te->parse($saida);

    my @auxiliar = ();
    foreach my $table ($te->table_states) {
      foreach my $row ($table->rows) {
        push( @auxiliar, join(',', @$row) . "\n");
      }
    }

   # Trata as informações e as salva no vetor @susep_lista
       @susep_lista = ();
    my $sep = "|";
    my ( $nome, $cnpj, $fip, $endereco, $cidade, $cep, $ddd, $tel, $fax, $data_autoriza );
   #$nome=$cnpj=$fip=$endereco=$cidade=$cep=$ddd=$tel=$fax=$data_autoriza='';

    my $linha_do_nome = 'nao';
    my $total_linhas = @auxiliar;

    for my $i (0 .. $total_linhas) {  # loop para rodar linha a linha do @auxiliar
      my $linha = $auxiliar[$i];
      chomp($linha);
      if ($i == 0 ) { # primeiro registro da @auxiliar

         $nome = $linha;
         $linha_do_nome = 'nao';
         next;

      } else {

        # se linha anterior é vazia, estamos na linha do nome
        if ( ($linha_do_nome eq 'sim') && ($linha !~ /Informações sobre/)) {
          $nome = $linha;
          $linha_do_nome = 'nao';
          next;
        }

        # se encontra 'CNPJ' na string, guarda-o na variável específica
        my $padrao_busca = "CNPJ: ";
        if ( $linha =~ m/$padrao_busca/ ) {
          $cnpj = substr( $linha, length($padrao_busca) );
          next;
        }

        # se encontra 'Código FIP: ' na string, guarda-o na variável específica
        $padrao_busca = "Código FIP: ";
        if ( $linha =~ m/$padrao_busca/ ) {
          $fip = substr( $linha, length($padrao_busca) );
          next;
        }

        # se encontra 'Endereço' na string, guarda-o na variável específica
        $padrao_busca = "Endereço: ";
        if ( $linha =~ m/$padrao_busca/ ) {
          $endereco = substr( $linha, length($padrao_busca) );
          next;
        }

        # se encontra 'Cep:' na string, guarda-o na variável específica
        $padrao_busca = "Cep: ";
        if ( $linha =~ m/$padrao_busca/ ) {
          $cidade = substr( $linha, 0, index($linha, $padrao_busca) - length(" - ") );
          $cep    = substr( $linha, index($linha, $padrao_busca) + length("Cep: ") );
          next;
        }

        # se encontra 'DDD' na string, guarda-o na variável específica
        $padrao_busca = "DDD: ";
        if ( $linha =~ m/$padrao_busca/ ) {
          $ddd = substr(
                        $linha,
                        length("DDD: "),
                        index($linha, "Tel: ") - index($linha, " - Tel: ") - 1
                       );

          $tel = substr(
                        $linha,
                        index($linha, "Tel: ") + length("Tel: "),
                        index($linha, " - Fax: ") - ( index($linha, "Tel: ") + length("Tel: "))
                       );

          $fax = substr( $linha, index($linha, "Fax: ") + length("Fax: ") );

          next;
        }

        # se encontra 'Data Autorização/Cadastramento: ' na string, guarda-o na variável específica
        $padrao_busca = "Data Autorização/Cadastramento: ";
        if ( $linha =~ m/$padrao_busca/ ) {
          $data_autoriza = substr( $linha, length($padrao_busca) );
          $linha_do_nome = 'sim';

          # este é o último campo. preenche vetor @susep_lista
          push(
               @susep_lista,
               join(
                    $sep,
                    $nome,
                    $cnpj,
                    $fip,
                    $endereco,
                    $cidade,
                    $cep,
                    $ddd,
                    $tel,
                    $fax,
                    $data_autoriza,
                    $tipo_empresa { $codigo_empresa }
                   )# . "\n"
              );

          next;
        }

      }

    }

   # Exporta informações para arquivo de texto, pronto para ser importado ao SQLite
    #my $output = '../fonte/'. $tipo_empresa { $codigo_empresa };
    #open( FILE, ">$output" ) || die "problema ao abrir $output\n";
    #print FILE @auxiliar;
    #close(FILE);

   # Exporta informações para arquivo 'Mercado_Supervisionado', pronto para ser importado ao SQLite
    $output = '../Mercado_Supervisionado';
    open( FILE, ">>$output" ) || die "problema ao abrir $output\n";
    print FILE @susep_lista;
    close(FILE);
}

open FILE, '<', '../Mercado_Supervisionado';
chomp(@susep_lista = <FILE>);
close FILE;

print LOG "\n\t\tarquivo para importação no SQLite: OK (Indicadores/SUSEP/Mercado_Supervisionado)";
print LOG "\n\t\tprimeiras 3 linhas:";
print LOG "\n\t\t\t".$susep_lista[0];
print LOG "\n\t\t\t".$susep_lista[1];
print LOG "\n\t\t\t".$susep_lista[2];
print LOG "\n\t\túltimas 3 linhas:";
print LOG "\n\t\t\t".$susep_lista[$#susep_lista-2];
print LOG "\n\t\t\t".$susep_lista[$#susep_lista-1];
print LOG "\n\t\t\t".$susep_lista[$#susep_lista  ];


close(LOG);
