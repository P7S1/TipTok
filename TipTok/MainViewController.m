//
//  MainViewController.m
//  TipTok
//
//  Created by Keng Fontem on 6/22/21.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipAmountSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *numberPad;
@property (weak, nonatomic) IBOutlet UILabel *finalBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipTokTitleLabel;

@end

@implementation MainViewController
//MARK:- Instance Variables
UILabel* tipAmountBalanceLabel;

//MARK:- View Initialization and Configuration Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self setUpMasterStackView];
    
    //Anytime the user changes the value, it updates the numbers
    [_numberPad addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self startEmitter];
    
}

//Creates a master stackview containing all the child stackviews
- (void)setUpMasterStackView{
    UIStackView* masterVerticalStackView = [[UIStackView alloc]init];
    [masterVerticalStackView setAxis:UILayoutConstraintAxisVertical];
    
    //Add all the child stackviews
    [masterVerticalStackView addArrangedSubview:_tipTokTitleLabel];
    [masterVerticalStackView addArrangedSubview:[self getBillStackView]];
    [masterVerticalStackView addArrangedSubview:[self getTipStackView]];
    [masterVerticalStackView addArrangedSubview: _tipAmountSegmentedControl];
    [masterVerticalStackView addArrangedSubview: _finalBalanceLabel];
    
    [self.view addSubview:masterVerticalStackView];
    
    //Activate constraints
    masterVerticalStackView.translatesAutoresizingMaskIntoConstraints = false;
    
    [NSLayoutConstraint activateConstraints:@[
        [masterVerticalStackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-128],
        [masterVerticalStackView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:16],
        [masterVerticalStackView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-16],
    ]];
    
    masterVerticalStackView.spacing = 8;

}

//MARK:- Helper Methods
//Gets reusable title label.
- (UILabel*) getTitleLabel: (NSString*) title{
    UILabel* label = [[UILabel alloc]init];
    label.text = title;
    label.translatesAutoresizingMaskIntoConstraints = false;
    return  label;
}

- (UIStackView*) getBasicHorizontalStackView{
    UIStackView* stackView = [[UIStackView alloc]init];
    [stackView setAxis:UILayoutConstraintAxisHorizontal];
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    return stackView;
}

//Calculates the total, and updates the UI
-(void)calculateTotalAndUpdateUI{
    double billAmount = _numberPad.text.doubleValue;
    double tipAmount = [self getTipPercentage] * billAmount;
    double finalTotal = (1 + [self getTipPercentage]) * billAmount;
    
    tipAmountBalanceLabel.text = [self getMoneyFormat:tipAmount];
    
    NSString *s = @"Total: ";
    _finalBalanceLabel.text = [s stringByAppendingString:[self getMoneyFormat:finalTotal]];
}

//Gets tip percentage for segmented control
-(double)getTipPercentage{
    switch (_tipAmountSegmentedControl.selectedSegmentIndex){
        case eightteenPercent:
            return 0.18;
        case fifteenPercent:
            return 0.15;
        case twentyPercent:
            return 0.2;
    }
    return 0.15;
}

//Formats a double into USD
-(NSString*)getMoneyFormat: (double)amount{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return [formatter stringFromNumber:[[NSNumber alloc]initWithDouble:amount]];
}

//MARK:- Master Stackview Components
/*
 1. Set up the bill stackview
 
 -It's just a horizontal stackview with a label and numberpad
*/
-(UIStackView*) getBillStackView{
    UILabel* titleLabel = [self getTitleLabel: @"Bill"];
    //Prevents issues with autolayout
    _numberPad.translatesAutoresizingMaskIntoConstraints = false;
     
    [[_numberPad.widthAnchor constraintEqualToConstant:200] setActive:true];
    _numberPad.backgroundColor = UIColor.secondarySystemBackgroundColor;
    [_numberPad setKeyboardType:UIKeyboardTypeNumberPad];
    
    UIStackView* stackView = [self getBasicHorizontalStackView];
    
    [stackView addArrangedSubview:titleLabel];
    [stackView addArrangedSubview:_numberPad];
    
    return stackView;
}

/*
 2. Create a tip stackView
 -It's just two labels on the opposite sides of each other
 */
-(UIStackView*) getTipStackView{
    UILabel* titleLabel = [self getTitleLabel: @"Tip"];
    tipAmountBalanceLabel = [self getTitleLabel: @"$0.00"];
    
    UIStackView* stackView = [self getBasicHorizontalStackView];
    
    [stackView addArrangedSubview:titleLabel];
    [stackView addArrangedSubview:tipAmountBalanceLabel];
    
    return stackView;
}

//MARK:- IB Actions
- (IBAction)segmentedControlValueChanged:(id)sender {
    [self calculateTotalAndUpdateUI];
}

//Not an IB outlet, but I couldn't get the value changed thing to work with an IB outlet ):
-(void)textFieldDidChange :(UITextField *) textField{
    [self calculateTotalAndUpdateUI];
}

//MARK:- Some fun stuff...CAEmitterLayer
-(void)startEmitter{
    UIView *emitterView = [[UIView alloc] init];
    CAEmitterLayer *emitterLayer = [[CAEmitterLayer alloc] init];
    
    emitterLayer.emitterPosition = CGPointMake(self.view.frame.size.width/2, -40);
    emitterLayer.emitterSize = CGSizeMake(self.view.frame.size.width, 1);
    emitterLayer.emitterShape = kCAEmitterLayerLine;
    emitterLayer.emitterCells = [self getEmitterCells];
    //emitterLayer.birthRate = 0.125;
    
    [emitterView.layer addSublayer:emitterLayer];
    emitterView.backgroundColor = UIColor.clearColor;
    emitterView.alpha = 0.7;
    [self.view addSubview:emitterView];
    [self.view sendSubviewToBack:emitterView];
    
    [NSLayoutConstraint activateConstraints:@[
        [emitterView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [emitterView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [emitterView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [emitterView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    ]];
    emitterView.translatesAutoresizingMaskIntoConstraints = false;
}

/*Gets emitter cells
 - Emoji Id is the corresponding emoji in Assets
 
 */
- (NSMutableArray<CAEmitterCell *> *) getEmitterCells{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5; i++){
        CAEmitterCell *cell = [[CAEmitterCell alloc] init];;
        cell.birthRate = 0.5;
        cell.lifetime = 20;
        cell.velocity = arc4random_uniform(50) + 50;
        cell.scale = 0.085;
        cell.scaleRange = 0.005;
        cell.emissionRange = M_PI/4;
        cell.emissionLatitude = (180 * (M_PI / 180));
        cell.alphaRange = 0.3;
        cell.yAcceleration = arc4random_uniform(10) + 10;
        
        NSString *emoji = @"emoji_";
        NSString *emojiId = [emoji stringByAppendingString: [@(i) stringValue]];
        cell.contents = (id) [[UIImage imageNamed:emojiId] CGImage];
        [cells addObject:cell];
    }
    
    return cells;
}

@end
