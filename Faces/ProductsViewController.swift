import UIKit
import FacesUI


class ProductsViewController: FacesViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, PayPalPaymentDelegate {
    @IBOutlet weak var userHelloLabel: HighlightedLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var topDescLabel: NormalLabel!
    @IBOutlet weak var descLabel: NormalLabel!
    @IBOutlet weak var nameLabel: NormalLabel!
    lazy var product = Product()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ga_title = "Products"
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        product.name = "iPhone 4"
        product.price = NSDecimalNumber(string: "21")
        product.desc = "asdsda sad asdasd  sdad"
        product.imagesURL = ["http://faces.hern.as/static/images/david_hasselhoff_3.jpg", "http://www.justvape247.com/ekmps/shops/justvape247/images/-NEW-IN-RED-APPLE-NATURAL-FW--16946-p.jpg"]
        
        self.userHelloLabel.text = "Hi \(self.api.user.name)!"
        if let image = self.api.user.avatar {
            self.userImageView.sd_setImageWithURL(image)
        }
        
        RACObserve(self.product, "name").subscribeNextAs { [weak self](name:String) -> () in
            self?.nameLabel.text = name
        }
        
        RACObserve(self.product, "desc").subscribeNextAs { [weak self](desc:String) -> () in
            self?.descLabel.text = desc
        }
        
        RACObserve(self.product, "images").subscribeNextAs { [weak self](desc:String) -> () in
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentNoNetwork)
        
    }
    
    @IBAction func logOutTapped(sender: AnyObject) {
        self.api.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        if let cell = cell as? ProductImageCell {
            cell.configure(product.images[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.product.images.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
    
    
    // MARK: ActionSheet
    
    @IBAction func buyNowTapped(sender: UIButton) {
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        self.actionSheet.addButtonWithTitle("Confirm payment")
        
        self.actionSheet.showFromRect(sender.frame, inView: self.view, animated: true)
    }
    var actionSheet:UIActionSheet!
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.payWithPayPal(self.product.price, name: self.product.name)
        }
    }
    
    // MARK: PayPal
    
    lazy var paypalConfiguration:PayPalConfiguration = {
        let conf = PayPalConfiguration()
        conf.payPalShippingAddressOption = PayPalShippingAddressOption.PayPal
        conf.acceptCreditCards = false
        return conf
    }()
    
    func payWithPayPal(amount:NSDecimalNumber, name:String) {
        let payment = PayPalPayment()
        payment.amount = amount
        payment.currencyCode = "EUR"
        payment.shortDescription = name
        payment.intent = PayPalPaymentIntent.Order
        if (!payment.processable) {
            // If, for example, the amount was negative or the shortDescription was empty, then
            // this payment would not be processable. You would want to handle that here.
        }
        
        let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.paypalConfiguration, delegate: self)
        self.presentViewController(paymentViewController, animated: true, completion: nil)
    }
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        DLOG("\(completedPayment)")
        
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}