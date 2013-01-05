//
//  ViewController.h
//  WebService
//
//  Created by Rafael Brigagão Paulino on 03/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (nonatomic, weak) IBOutlet UILabel *escalaOrigem;
@property (nonatomic, weak) IBOutlet UILabel *escalaDestino;
@property (nonatomic, weak) IBOutlet UILabel *resultado;
@property (nonatomic, weak) IBOutlet UITextField *campoTexto;
@property (nonatomic, weak) IBOutlet UISegmentedControl *tipoConversao;

-(IBAction)botaoConverterClicado:(id)sender;
-(IBAction)tipoConversaoMudou:(id)sender;

@end
