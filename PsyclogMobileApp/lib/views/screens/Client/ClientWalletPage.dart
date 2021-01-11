import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_card/credit_card.dart';
import 'package:awesome_card/style/card_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientWalletPage extends StatefulWidget {
  @override
  _ClientWalletPageState createState() => _ClientWalletPageState();
}

class _ClientWalletPageState extends State<ClientWalletPage> {
  WebServerService _webServerService;
  User _currentUser;
  PageController _pageController;

  MaskedTextController _cardNumberController;
  TextEditingController _cardHolderController;
  TextEditingController _expiryMonthController;
  TextEditingController _expiryYearController;
  TextEditingController _cvvController;
  TextEditingController _moneyAmountController;

  bool showBack = false;

  FocusNode _focusNode;

  @override
  void initState() {
    _pageController = PageController(initialPage: 1);

    _cardNumberController = MaskedTextController(mask: '0000 0000 0000 0000');
    _cardHolderController = TextEditingController();
    _expiryYearController = TextEditingController();
    _expiryMonthController = TextEditingController();
    _cvvController = TextEditingController();
    _moneyAmountController = TextEditingController();

    // TODO: implement initState
    super.initState();
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
  }

  Future<bool> initializeService() async {
    _webServerService = await WebServerService.getWebServerService();

    _currentUser = _webServerService.currentUser;

    if (_currentUser != null) {
      return true;
    } else
      return false;
  }

  Future<bool> uploadMoney() async {
    final String cardHolderName = _cardHolderController.text;
    final String cardCVC = _cvvController.text;
    final String cardNumber = _cardNumberController.text.replaceAll(" ", "");
    final String expMonth = _expiryMonthController.text;
    final String expYear = "20" + _expiryYearController.text;
    final int moneyAmount = int.parse(_moneyAmountController.text);

    bool isUploaded =
        await _webServerService.uploadMoney(cardHolderName, cardCVC, cardNumber, expMonth, expYear, moneyAmount);

    if (isUploaded) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> withdrawMoney() async {
    final String cardHolderName = _cardHolderController.text;
    final String cardCVC = _cvvController.text;
    final String cardNumber = _cardNumberController.text.replaceAll(" ", "");
    final String expMonth = _expiryMonthController.text;
    final String expYear = "20" + _expiryYearController.text;
    final int moneyAmount = int.parse(_moneyAmountController.text);

    bool isWithdrawn =
        await _webServerService.withdrawMoney(cardHolderName, cardCVC, cardNumber, expMonth, expYear, moneyAmount);

    if (isWithdrawn) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _moneyAmountController.dispose();
    _cvvController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstants.myWhite,
      body: FutureBuilder(
        future: initializeService(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(4, 4),
                        colors: [ViewConstants.myWhite, ViewConstants.myBlack]),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                          iconTheme: IconThemeData(
                            color: ViewConstants.myBlack,
                          ),
                          automaticallyImplyLeading: false,
                          actions: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  setState(() {
                                    _cvvController.clear();
                                    _expiryMonthController.clear();
                                    _expiryYearController.clear();
                                    _cardNumberController.clear();
                                    _cardHolderController.clear();
                                    _moneyAmountController.clear();
                                  });

                                  _pageController.animateToPage(1,
                                      duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                                },
                              ),
                            ),
                          ],
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          centerTitle: true,
                          title: Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            width: MediaQuery.of(context).size.width / 3,
                            child: Image.asset(
                              "assets/PSYCLOG_black_text.png",
                              fit: BoxFit.fitWidth,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CreditCard(
                          cardNumber: _cardNumberController.text,
                          cardExpiry: _expiryMonthController.text + "/" + _expiryYearController.text,
                          cardHolderName: _cardHolderController.text,
                          cvv: _cvvController.text,
                          showBackSide: showBack,
                          frontBackground: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment(2, 2),
                                  colors: [ViewConstants.myBlack, ViewConstants.myYellow]),
                            ),
                          ),
                          backBackground: CardBackgrounds.white,
                          showShadow: true,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: ViewConstants.myWhite,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: TextFormField(
                                          controller: _cardNumberController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.credit_card,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterText: "",
                                            hintText: 'Type your card number',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          maxLength: 19,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                controller: _expiryMonthController,
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.date_range_outlined,
                                                    color: ViewConstants.myBlack,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  counterText: "",
                                                  hintText: 'Month',
                                                  hintStyle: TextStyle(
                                                      fontSize: 13,
                                                      color: ViewConstants.myBlack.withOpacity(0.5),
                                                      fontWeight: FontWeight.w400),
                                                ),
                                                style: TextStyle(
                                                    fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                maxLength: 2,
                                              ),
                                            ),
                                            VerticalDivider(),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _expiryYearController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.date_range,
                                                    color: ViewConstants.myBlack,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  counterText: "",
                                                  hintText: 'Year',
                                                  hintStyle: TextStyle(
                                                      fontSize: 13,
                                                      color: ViewConstants.myBlack.withOpacity(0.5),
                                                      fontWeight: FontWeight.w400),
                                                ),
                                                style: TextStyle(
                                                    fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                maxLength: 2,
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: TextFormField(
                                          controller: _cardHolderController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.person,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterStyle: TextStyle(
                                                fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            hintText: 'Type your card holder name',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _cvvController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterStyle: TextStyle(
                                                fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            hintText: 'Type your card CVV',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          maxLength: 3,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                          focusNode: _focusNode,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _moneyAmountController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.attach_money,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterStyle: TextStyle(
                                                fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            hintText: 'The money amount',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: ViewConstants.myBlack,
                                        ),
                                        child: FlatButton(
                                          minWidth: MediaQuery.of(context).size.width,
                                          onPressed: () {},
                                          child: Text(
                                            "Upload",
                                            style: GoogleFonts.muli(fontSize: 18),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(5, 5),
                              colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SafeArea(
                                top: true,
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Image.asset(
                                    "assets/PSYCLOG_black_text.png",
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 60.0, bottom: 25),
                                child: Container(
                                  margin: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ViewConstants.myBlack, width: 5),
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment(1, 1),
                                        colors: [ViewConstants.myGrey, ViewConstants.myBlue]),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: AutoSizeText(
                                            "Total Balance",
                                            style: GoogleFonts.muli(color: ViewConstants.myWhite),
                                            minFontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: FutureBuilder(
                                            future: _webServerService.getBalance(),
                                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                              if (snapshot.hasData) {
                                                return AutoSizeText(
                                                  snapshot.data.toString() + " TL",
                                                  style: GoogleFonts.muli(
                                                      color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                  minFontSize: 25,
                                                );
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment(1, 1),
                                colors: [ViewConstants.myGrey, ViewConstants.myBlack]),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Dismissible(
                                  key: UniqueKey(),
                                  child: Card(
                                    color: ViewConstants.myBlack,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: AutoSizeText(
                                          "You can add funds to your wallet or withdraw from it.",
                                          style: GoogleFonts.muli(color: ViewConstants.myWhite),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 30.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(color: ViewConstants.myWhite, width: 2),
                                                top: BorderSide(color: ViewConstants.myWhite, width: 2),
                                                bottom: BorderSide(color: ViewConstants.myWhite, width: 2)),
                                            gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment(1, 1),
                                                colors: [ViewConstants.myGrey, ViewConstants.myPink]),
                                          ),
                                          child: FlatButton(
                                            splashColor: ViewConstants.myYellow,
                                            padding: EdgeInsets.symmetric(vertical: 40),
                                            onPressed: () {
                                              _pageController.animateToPage(2,
                                                  duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20.0),
                                                  child: Icon(Icons.arrow_forward),
                                                ),
                                                Expanded(
                                                    child: Center(
                                                        child: Text(
                                                  "Withdraw",
                                                  style: GoogleFonts.muli(fontSize: 18),
                                                ))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 30.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(color: ViewConstants.myWhite, width: 2),
                                                top: BorderSide(color: ViewConstants.myWhite, width: 2),
                                                bottom: BorderSide(color: ViewConstants.myWhite, width: 2)),
                                            gradient: LinearGradient(
                                                begin: Alignment.centerRight,
                                                end: Alignment(-1, -1),
                                                colors: [ViewConstants.myGrey, ViewConstants.myYellow]),
                                          ),
                                          child: FlatButton(
                                            splashColor: ViewConstants.myPink,
                                            padding: EdgeInsets.symmetric(vertical: 40),
                                            onPressed: () {
                                              _pageController.animateToPage(0,
                                                  duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: Center(
                                                        child: Text(
                                                  "Upload",
                                                  style: GoogleFonts.muli(fontSize: 18),
                                                ))),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 20.0),
                                                  child: Icon(Icons.arrow_back),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(4, 4),
                        colors: [ViewConstants.myWhite, ViewConstants.myBlack]),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                          iconTheme: IconThemeData(
                            color: ViewConstants.myBlack,
                          ),
                          automaticallyImplyLeading: false,
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                _cvvController.clear();
                                _expiryMonthController.clear();
                                _expiryYearController.clear();
                                _cardNumberController.clear();
                                _cardHolderController.clear();
                                _moneyAmountController.clear();
                              });

                              _pageController.animateToPage(1,
                                  duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                            },
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          centerTitle: true,
                          title: Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            width: MediaQuery.of(context).size.width / 3,
                            child: Image.asset(
                              "assets/PSYCLOG_black_text.png",
                              fit: BoxFit.fitWidth,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CreditCard(
                          cardNumber: _cardNumberController.text,
                          cardExpiry: _expiryMonthController.text + "/" + _expiryYearController.text,
                          cardHolderName: _cardHolderController.text,
                          cvv: _cvvController.text,
                          showBackSide: showBack,
                          frontBackground: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment(2, 2),
                                  colors: [ViewConstants.myBlack, ViewConstants.myPink]),
                            ),
                          ),
                          backBackground: CardBackgrounds.white,
                          showShadow: true,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: ViewConstants.myWhite,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: TextFormField(
                                          controller: _cardNumberController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.credit_card,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterText: "",
                                            hintText: 'Type your card number',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          maxLength: 19,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                controller: _expiryMonthController,
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.date_range_outlined,
                                                    color: ViewConstants.myBlack,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  counterText: "",
                                                  hintText: 'Month',
                                                  hintStyle: TextStyle(
                                                      fontSize: 13,
                                                      color: ViewConstants.myBlack.withOpacity(0.5),
                                                      fontWeight: FontWeight.w400),
                                                ),
                                                style: TextStyle(
                                                    fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                maxLength: 2,
                                              ),
                                            ),
                                            VerticalDivider(),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _expiryYearController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.date_range,
                                                    color: ViewConstants.myBlack,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myBlack),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: ViewConstants.myPink),
                                                  ),
                                                  counterText: "",
                                                  hintText: 'Year',
                                                  hintStyle: TextStyle(
                                                      fontSize: 13,
                                                      color: ViewConstants.myBlack.withOpacity(0.5),
                                                      fontWeight: FontWeight.w400),
                                                ),
                                                style: TextStyle(
                                                    fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                maxLength: 2,
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: TextFormField(
                                          controller: _cardHolderController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.person,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterStyle: TextStyle(
                                                fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            hintText: 'Type your card holder name',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _cvvController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterStyle: TextStyle(
                                                fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            hintText: 'Type your card CVV',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          maxLength: 3,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                          focusNode: _focusNode,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _moneyAmountController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.attach_money,
                                              color: ViewConstants.myBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack.withOpacity(0.25)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myBlack),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: ViewConstants.myPink),
                                            ),
                                            counterStyle: TextStyle(
                                                fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            hintText: 'The money amount',
                                            hintStyle: TextStyle(
                                                fontSize: 13,
                                                color: ViewConstants.myBlack.withOpacity(0.5),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          style: TextStyle(
                                              fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: ViewConstants.myBlack,
                                        ),
                                        child: FlatButton(
                                          minWidth: MediaQuery.of(context).size.width,
                                          onPressed: () {},
                                          child: Text(
                                            "Withdraw",
                                            style: GoogleFonts.muli(fontSize: 18),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
