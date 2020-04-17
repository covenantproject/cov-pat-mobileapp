import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class TextStyleFormate{
  labelfont(){
    var textstyle=TextStyle(fontSize: 16,
    color: Colors.blue[600],fontWeight: FontWeight.bold);
     return textstyle;
  }
  cardfont(){
    var cardstyle=TextStyle(fontWeight: FontWeight.bold, fontSize: 19);
    return cardstyle;
  }
  buttoncard(){
    var buttonstyle=TextStyle(fontWeight: FontWeight.w600,fontSize: 13);
    return buttonstyle;
  }
  placeholderStyle(){
    var placeholder=TextStyle(fontSize: 16,fontFamily: 'Schyler');
    return placeholder;
  }
  dropDownPlaceHolderstyle(){
    var dropDownplaceholder=TextStyle(fontSize: 15,fontFamily: 'Schyler');
    return dropDownplaceholder;
  }
  moreoption(){
    var moreoption=TextStyle(color: Colors.amber[700],fontWeight: FontWeight.w600);
    return moreoption;
  }
  emptylist(){
    var emptylisttext=TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
    return emptylisttext;
  }
   headerStyle(){
      var headerStyle=TextStyle(fontWeight: FontWeight.w600,fontSize:19);
      return headerStyle;

    }
}