//
//  ViewController.m
//  WebService
//
//  Created by Rafael Brigagão Paulino on 03/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableURLRequest *requisicao;
    NSString *corpoRequisicao;
    
    //para receber a resposta da requisicao
    NSMutableData *dadosRecebidos;
    NSXMLParser *leitorXML;
    NSString *tagProcurada;
    
    BOOL devolerCaracter;
    
    NSMutableString *conteudo;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tagProcurada = @"m:CelciusToFahrenheitResult";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)botaoConverterClicado:(id)sender
{
    [_campoTexto resignFirstResponder];
    
    //inicio da elaboracao da requisicao
    
    //onde esta disponivel o servico
    NSURL *url = [NSURL URLWithString:@"http://webservices.daehosting.com/services/TemperatureConversions.wso"];
    
    //inicializando a requisicao com o endereco
    requisicao = [NSMutableURLRequest requestWithURL:url];
    
    //configurar o cabecalho da requisicao
    [requisicao setHTTPMethod:@"POST"];
    
    [requisicao setValue:@"webservices.daehosting.com" forHTTPHeaderField:@"Host"];
    [requisicao setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [requisicao setValue:@"utf-8" forHTTPHeaderField:@"charset"];
    
    
    //configurar o corpo da requisicao
    if (_tipoConversao.selectedSegmentIndex == 0)
    {
        //c->f
        corpoRequisicao = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><CelciusToFahrenheit xmlns=\"http://webservices.daehosting.com/temperature\"><nCelcius>%@</nCelcius></CelciusToFahrenheit></soap:Body></soap:Envelope>",_campoTexto.text];
    }
    else
    {
        //f->c
        corpoRequisicao = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><FahrenheitToCelcius xmlns=\"http://webservices.daehosting.com/temperature\"><nFahrenheit>%@</nFahrenheit></FahrenheitToCelcius></soap:Body></soap:Envelope>",_campoTexto.text];
    }
    
    //criar um NSData a partir da NSSString do corpo da requisicao
    NSData *corpoData = [corpoRequisicao dataUsingEncoding:NSUTF8StringEncoding];
    
    //associar esse corpo ao cabecalho
    [requisicao setHTTPBody:corpoData];
    
    //inicializando o NSMutable data onde guardaremos os pacotes que recebemos como resposta
    dadosRecebidos = [[NSMutableData alloc] init];
    
    //estabalecer a conexao com o servidor webservice
    [NSURLConnection connectionWithRequest:requisicao delegate:self];
    
    //respostas serao tratadas via metodo delegate da classe NSURLConnection
 
}

//NSXMLParserDelegate
#pragma delegates do xml
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //so faco algo se o elemento abrindo for a tag que estou esperando como reposta
    if ([elementName isEqualToString:tagProcurada])
    {
        devolerCaracter = YES;
        conteudo = [[NSMutableString alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:tagProcurada])
    {
        devolerCaracter = NO;
        _resultado.text = conteudo;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (devolerCaracter == YES)
    {
        [conteudo appendString:string];
    }
}


//metodos delegate do NSURLConnectionData
#pragma Metodos delegate do NSURLConnectionData

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //estamos recebendo varios pacotes, onde cada um deles e o parametro data deste metodo
    if (data != nil)
    {
        //se o pacote nao esta vazio, acumular os dados do pacote em nosso NSMUtableData cahmado dados Recebidos
        [dadosRecebidos appendData:data];
    }
}

//primeito meotodo chamado quando recebemos uma resposta do servidor
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Sucesso na conexao, vou comecar a receber pacotes");
}

//metodo chamado quando todos os pacotes acabaram de chegar no servidor
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //criando uma string a paertir dos dados recebidos para poder enxergar a resposta no console
    NSString *stringVisualizacao = [[NSString alloc] initWithData:dadosRecebidos encoding:NSUTF8StringEncoding];
    
    NSLog(@"XML Resposta: %@", stringVisualizacao);
    
    leitorXML = [[NSXMLParser alloc] initWithData:dadosRecebidos];
    leitorXML.delegate = self;
    [leitorXML parse];
}


//botao conversao mudou
#pragma botao conversou mudou

-(IBAction)tipoConversaoMudou:(id)sender
{
    if(_tipoConversao.selectedSegmentIndex == 0)
    {
        _escalaOrigem.text = @"ºC";
        _escalaDestino.text = @"ºF";
        
        tagProcurada = @"m:CelciusToFahrenheitResult";
    }
    else
    {
        _escalaOrigem.text = @"ºF";
        _escalaDestino.text = @"ºC";
        
        tagProcurada = @"m:FahrenheitToCelciusResult";
    }
}

@end
