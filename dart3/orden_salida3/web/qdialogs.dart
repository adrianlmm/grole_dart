// ignore_for_file: unused_element, non_constant_identifier_names, avoid_init_to_null, constant_identifier_names
import 'package:web/web.dart';
import 'dart:async';

extension JExtensions on DOMStringMap {
  external String operator [](String name);
  external void operator []=(String name, String value);
  void delete(String name) => delete(name);
}

extension HTMLCollectionsExtensios on HTMLCollection {
  void clear() {
    for (var i = length - 1; i >= 0; i--) {
      item(i)!.remove();
    }
  }

  external Element? operator [](int index);
}

extension DocumentExtensions on Document {
  HTMLAnchorElement createAnchor() {
    return document.createElement('A') as HTMLAnchorElement;
  }

  HTMLTableCellElement createTableCell() {
    return document.createElement('TD') as HTMLTableCellElement;
  }

  HTMLTableRowElement createTableRow() {
    return document.createElement('TR') as HTMLTableRowElement;
  }

  HTMLDivElement createDiv() {
    return document.createElement('DIV') as HTMLDivElement;
  }

  HTMLDialogElement createDialog() {
    return document.createElement('DIALOG') as HTMLDialogElement;
  }

  HTMLInputElement createInput() {
    return document.createElement('INPUT') as HTMLInputElement;
  }

  HTMLButtonElement createButton() {
    return document.createElement('BUTTON') as HTMLButtonElement;
  }

  HTMLImageElement createImage() {
    return document.createElement('IMG') as HTMLImageElement;
  }

  HTMLHeadingElement createHeading(String ATipo) {
    return document.createElement(ATipo) as HTMLHeadingElement;
  }
}

enum TDialogType { INFO, WARNING, ERROR, QUESTION }

enum TDialogResult { OK, CANCEL, YES, NO }

enum TDialogButtons { OK, OK_CANCEL, YES_NO }

String _questionImageBase64 =
    'data:image/png;base64,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';
String _errorImageBase64 =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHYAAAByCAIAAAAJVLJQAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAATXSURBVHhe7ZsxaxVBEMdjgilEEOwtVJIq+CEsbAQLC3tBsLKyyGewtvUTWFgIdpIPIakiamFvFYJEYlzY5XLu3e7NzM7MztvbX+MG3rv9z+/mzd27xGuXl5dbHUnsKv51Zy+slrj982tYmcSQYrjTRUxJr6yYUWuK6rrrKFYwO6WWa1XFVcxOUXatpNiI3DFqosUVl8gFWlDYogRBxdjKGautuPUUKcXwIkXLQ7kWSsKvGFiVwid0TMVUzIoXK1E2OwXimjckm2IJuXKtp9kKPIrzieFxgU7zcG3HZZlBcWFQFq0pIJoyAVgsFym2LDciH6awkDx0xeRYmmYjyKlKLBMVZwLZlDuGlpBsmaJ4o/0OpKKyW0YrJiSwJndAxzJOcUt+PRllqeRYywyKN1TuGFQJWMXb4V8AKGUb5NeRSjtrE1saVLFoCAugMqNeDBoUzfsdMy0KVf4UxKCIaNLvLCmVwGKXFc8eqGG/8HqBLChem18Pb9XoQdG8Xw/c8iI5xUBx7fn1cJWP6+LpaWzVr2daHeFDnFQMcde2X095jYgupk2i9sA28rzi6RvWNiLGQGxkmP92V0fxg8Nbn17shB8I/Pj9+NHZl/ADO5EBuPeZLq7jd+vgxtsSv467158chKU8cCe4OwpJ9rfvhZVNyF0VK4YcSKCFNxJgIy93cWrErBBab6EHheEW/vHn43FYWuK/O4qpPpULnefpzZ9vdsN6xOfDX88/hLUBIEKi1+C62HALK0EwYOeOolm6YnGuFC/OlD4lPJGHxencu1icrlicrlicrlic8NXDwLUu8dUDxNHpnZfnYa3Eop/hBW108cPdZ2FlkEYGxc6+3pNiLH0Wi9OI4osTi8/YPG0oPjp/H1YGMX9HYexh5sDa7ihM0xWL0xWL0xWL0xWLk1QcXSKjC+jKQd1u9S4WJyjuTcrL2GfvYnG6YnGu/hpodmaj5noZJY/kA+ev907lH1ZMh2rm27OjqS6u8tR4se2uFDdwxdu5vx9WVYlM4rq4gdNQCMHAgmLJ4Rtx8vd7WJG5+HYSVlpA/NiZxcdnr95dhDURm7/7iP/H0uxpiT4diq1ti+mUmKqYvqapOwplgK1GUbzOix656ljx7IEgH4e1AZmonj4oQJS01Izi3sgR00qBU9iD6GLUcVdIqufmFQM7dA2NXNjCDtwsXtu4gPvNeEgqhrtr1TJXXbgudsyexvYsz1ZEaGFHTnHqnc1bZvTrQHexp2HLKL8QFhRnrJXsullkKoV0VfykbRbsHhtqn1ALRDFxUOSBbGwNQmbgW0CKM8dKneTNspxKWzgiPKBB4aHtZ39oiPp1IBQ78r4IWetCDoxSzDmLU8lQgdTQ8evAdbGjJIGRdi5JSGgXtGIHxJRN0XlBEn4dFMWOQssOZdHlYWh+HUTFDq5Yoq65ApD9OuiKHUA78Hwsutm3K/HrKFLsgEshBJVTIBo7olSxRzNxIfpReRQ74NE9+q5RCRnjsSl2YC17pF0TUvFG4lTsoYl2MBZmIcMAv2IHucIIYMHK22ERUezhqlwBIbkeQcUe46JF5XrEFXsMilaQ61FS7DEiWk2uR1XxQBXXymYH6igeUHBdy+xAZcVjGHVX1zrGkOIIlHFTTiPsKm4GkT9V6YzpioXZ2voHFZ308/frsswAAAAASUVORK5CYII=';
String _warningImageBase64 =
    'data:image/png;base64,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';
String _infoImageBase64 =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHYAAAByCAYAAACGNiUHAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAATRSURBVHhe7Z2/ThVBFIdXa+EBILGQ1o5CGwuIpdj4AFa+g4Wlb+Ez2KilwcJGCzpbGxN4ALBXh8zgsndmZ86fmTlz7vkS4hLh7pzft7/ZzQ2BO3/+MRnqUCX24MOJP4Lx8/lHf6SHYcViJUIYWfgwYluIzDGSaNFiJchMIV2yOLGSZaaQKFmM2BGFLpEkuLtYbqGYcCWsgZtuYqlhtghvhDWm6CIWG1jPoCiSe6y7qVhMOBK2tSUjzNFMLCQMiTJTQCW3mq262NZCe7VJ2oVbVWzpsNhBMRJLqb2m2nKria0xYE2ROaAiStZaUy67WG1CY5SuvUYWpbCK5RxEmswYnHNwy2UTWzKAFqFLuObilMsidpulzsnN2FIuWSzHYkcXOkeKXJJYkxqnRExubqrcamK3UegSSgZUsXf9v2AoYrZBqiM355o8akYosT0XPBqUeSnfC96KTSqeVDaUTFOgt+IYJhVHThwmO5DYtROY1DzY/DAUizWpPLTKkbwVm1Q4WLkQisRiBJnUdWpnSmps6uoyqWWkcuLYBbNioZJMKoxaeaEby3UvMOJQW7sqNvUCtgXzAs25BNI9VjT7b66DWX682/f/LwzuUiTFDt1WJ/Xwkf/kNseHcuXGwOatsrEv9uJSA8d7R/5IFpzliIqFnkBUW0u4d3966A9HANNaUGNTJzD44CoJeSserq2O37+mH/5QKxtiU6JGauv7i+/+KM7pxRd/NA7Q7ZjUWLFtPX87HZzF5Z6enUyvzv0nQuHIdeMnKCCNFStWAZC8Y19LvscaMrkl1toqh1i+kPusNVYpSsU+mF4fbb5PfP1x9HKoNyew6BS7+2R6uuOPl+w8np7t+mPF2FaslBux9uAkD8oDlDVWKSZWKSZWKSZWKSZWKSZWKSZWKSZWKSZWKSZWKSZWKVmxkPcrDV4o79NbY5VyI9ZaODZLf9ZYpZhYpRSJtQeo9lDztcYOROkTseOWWGvhmMS8kRprF0IdOHItFgvZBgx+oPnbPVYpG2LXtgF7Oq4PNM/U1+ts7OXX6fOVP15y9W36dOmPBwFzG4z+hvG1F0pdIXYPpoPJFtTYte0gdZK17zHwYKQ67OFJCNzFSIq11rYjlRvl9oZuLOWkBp1ciVbFYhporYVRo60O0j3WtmQaWKkl+WbFYiWZ3HVq50NqrGPt6jK5cdZy4Wiro0hs7sVMbjktpDrIjQ2Y3DwUqVCKxZbI4V7ctlCSG7Qc7H+N0tHyyhwBjjygYtm24lKgCxwdjnkxrwEWW3KS3FW4LXJzc9bYggPov9HOtSitW3NPqQ60WEepFI4hR4FzVorYJvfY3DCUASQhRaqD1FgH92JHbC/3XBwXOlmsAypDi+BSAa2lOljEOmrIdUgUXGvtXFIdbGIdtQfpKbn2WjmlOljFOjDhY4eqKbrlmrilOtjFOrCBcwzYK9ieM8eoIjYgbdgaSJ2xqlgHdvCAVMmUuVrMVF2sgyo30FsyxxytZmgiNsAl2NEioNHWO6epWAdnWDEwAUpcE5XmYgO1w5RAD6GBbmIDGgX3FBroLjagQbAEoQExYgMjCpYkNCBO7BzJkiXKnCNa7BwJkqXLnDOM2CUtRI8kcsmwYmNQZI8sMYYqscZ/mv/AuNEGE6uSafoLxi0N/IgoH8EAAAAASUVORK5CYII=';

HTMLDivElement _getWindowDivWeb(String AWidth, String AHeight) {
  var m1 = document.createDiv()
    ..style.width = AWidth
    ..style.height = AHeight
    ..style.position = 'fixed'
    ..style.backgroundColor = 'white'
    ..style.borderColor = 'gray'
    ..style.borderWidth = '1px'
    ..style.borderStyle = 'solid'
    ..style.zIndex = '9999'
    ..style.boxShadow = '5px 5px 3px #888888';

  var iw = window.innerWidth;
  var ih = window.innerHeight;
  var x = ((iw / 2) - 200).round();
  var y = ((ih / 2) - 250).round();

  m1.style.top = '${y}px';
  m1.style.left = '${x}px';

  m1.style.padding = '0px';

  return m1;
}

HTMLDivElement _getTitleDivWeb(String ATitle) {
  var h3 = document.createHeading('H3')
    ..innerText = ATitle
    ..style.marginBottom = '0px'
    ..style.marginBottom = '0px';

  var divItemTitle = document.createDiv()
    ..appendChild(h3 as Element)
    ..style.textAlign = 'center'
    ..style.backgroundColor = 'rgb(240, 240, 240)'
    ..style.borderBottomStyle = 'solid'
    ..style.borderColor = 'black'
    ..style.borderWidth = '1px'
    ..style.height = '25px'
    ..style.padding = '5px';

  h3.style.marginTop = '0px';
  h3.style.marginBottom = '0px';

  return divItemTitle;
}

Future<String?> inputTextWeb(String AText, String ATitle, {bool Password = false}) {
  var pResult = Completer<String>();

  var dlg = document.createDialog();
  dlg.style.borderWidth = '0px';
  dlg.style.backgroundColor = 'transparent';
  document.body?.appendChild(dlg);

  var m1 = _getWindowDivWeb("400px", "200px");
  dlg.appendChild(m1);

  var divItemTitle = _getTitleDivWeb(ATitle);
  m1.appendChild(divItemTitle);

  var divItemContainer = document.createDiv();
  divItemContainer.style.height = "100px";
  divItemContainer.style.overflowY = "auto";
  m1.appendChild(divItemContainer);

  Function? fComplete(String? AResult) {
    pResult.complete(AResult);
    dlg.close();
    dlg.remove();
    return null;
  }

  dlg.onKeyDown.listen((KeyboardEvent event) {
    var code = event.which;

    if (code == 13) {
      var inpText = document.querySelector("#inpText") as HTMLInputElement;

      fComplete(inpText.value);
      event.preventDefault();
      event.stopPropagation();
    }

    if (code == 27) {
      fComplete(null);
      event.preventDefault();
      event.stopPropagation();
    }
  });

  var inpText = document.createInput()..id = "inpText";

  if (Password) {
    inpText.type = 'password';
  }

  inpText.style.paddingTop = "13px";
  inpText.style.marginTop = "30px";
  inpText.style.marginLeft = "50px";
  inpText.style.height = "20px";
  inpText.style.padding = "5px";
  inpText.style.width = "300px";
  inpText.value = AText;

  divItemContainer.appendChild(inpText);

  var divButtonContainer = document.createDiv()
    ..style.borderTopStyle = "solid"
    ..style.borderColor = "silver"
    ..style.borderWidth = "1px"
    ..style.paddingRight = "30px";

  var btnOK = document.createButton()
    ..text = 'Aceptar'
    ..style.float = "right"
    ..style.marginTop = "20px"
    ..style.marginRight = "5px";
  btnOK.onClick.listen((_) {
    fComplete(inpText.value);
  });

  var btnCancel = document.createButton()
    ..text = 'Cancelar'
    ..style.float = "right"
    ..style.marginTop = "20px"
    ..style.marginRight = "5px";
  btnCancel.onClick.listen((_) {
    fComplete(null);
  });

  divButtonContainer.appendChild(btnOK);
  divButtonContainer.appendChild(btnCancel);

  m1.appendChild(divButtonContainer);

  dlg.showModal();
  inpText.focus();
  inpText.select();

  return pResult.future;
}

Future<Map<String, String>?>? pickListWeb(dynamic AList, String ATitle, {String AKey = "Key", String AValue = "Value", String AMark = "", dynamic ASelected}) {
  var pResult = Completer<Map<String, String>?>();

  var dlg = document.createDialog();
  document.body?.appendChild(dlg);

  var m1 = _getWindowDivWeb("400px", "450px");

  var divItemTitle = _getTitleDivWeb(ATitle);
  m1.appendChild(divItemTitle);

  var divItemContainer = document.createDiv()..id = "divItemContainer";
  divItemContainer.style.height = "330px";
  divItemContainer.style.overflowY = "auto";
  m1.appendChild(divItemContainer);
  dlg.appendChild(m1);

  Function? fComplete(Map<String, String>? AMap) {
    pResult.complete(AMap);
    dlg.close();
    dlg.remove();
    return null;
  }

  dlg.onKeyDown.listen((KeyboardEvent event) {
    event.preventDefault();

    var code = event.which;

    if (code == 13 || code == 32) {
      print(code);
      if (document.querySelector(".selected") == null) {
        return;
      }

      var divItem = document.querySelector(".selected") as HTMLDivElement;

      var pMapResult = <String, String>{};

      pMapResult[AKey] = divItem.attributes.getNamedItem("data-value").toString();
      pMapResult[AValue] = divItem.innerText;

      fComplete(pMapResult);
      event.preventDefault();
      event.stopPropagation();
    }

    if (code == 27) {
      fComplete(null);
      event.preventDefault();
      event.stopPropagation();
    }

    vSelect(int action) {
      if (document.querySelector(".selected") == null) {
        return;
      }

      var divItem = document.querySelector(".selected") as HTMLDivElement;

      int idDiv = 0;

      //Select item below
      if (action == 40) {
        idDiv = int.parse(divItem.attributes.getNamedItem("data-index").toString()) + 1;
      }
      //Select upper item
      else if (action == 38) {
        idDiv = int.parse(divItem.attributes.getNamedItem("data-index").toString()) - 1;
      } else if (action == 34) {
        idDiv = int.parse(divItem.attributes.getNamedItem("data-index").toString()) + 7;
      } else if (action == 33) {
        idDiv = int.parse(divItem.attributes.getNamedItem("data-index").toString()) - 7;
      }

      var divNewItem = document.querySelector("#item$idDiv") as HTMLDivElement?;

      if (divNewItem == null) {
        return;
      }

      print('10');
      divItem.classList.remove("selected");
      divItem.style.backgroundColor = "white";
      divNewItem.classList.add("selected");
      divNewItem.style.backgroundColor = "rgb(212, 220, 250)";
      divNewItem.focus();

      print('11');

      var a = ScrollIntoViewOptions();
      a.block = 'block';
      a.inline = 'inline';

      if (action == 2) {
        divNewItem.scrollIntoView(a);
      }

      print('12');

      if (action == 3) {
        divNewItem.scrollIntoView(a);
      }
    }

    vSelect(code);
  });

  int i = 0;

  HTMLDivElement? divItemTmp = null;
  HTMLDivElement? divItemFirst = null;
  bool pFound = false;

  for (var item in AList) {
    print(item);
    print(item.runtimeType);
    var divItem = document.createDiv()
      ..style.paddingTop = "13px"
      ..style.verticalAlign = "center"
      ..style.paddingLeft = "5px"
      ..classList.add("divItem")
      ..id = "item$i"
      ..tabIndex = i + 20
      ..setAttribute("data-value", item [AKey].toString())
      ..setAttribute("data-index", i.toString())
      ..style.height = "30px"
      ..style.cursor = 'default';

    if (ASelected != null) {
      if (ASelected == item[AKey]) {
        divItem.classList.add("selected");
        divItem.style.background = "rgb(212, 220, 250)";
        divItemTmp = divItem;
        pFound = true;
      }
    } else {
      if (i == 0) {
        divItem.style.background = "rgb(212, 220, 250)";
        divItem.classList.add("selected");
      }
    }

    if (i == 0) {
      divItemFirst = divItem;
    }

    i++;

    if (AMark == "") {
      divItem.text = item[AValue];
    } else {
      //We hightlight the specified text
      try {
        var pHtmlElement = "<span>${item[AValue]}</span>";
        //pHtmlElement = pHtmlElement.toUpperCase();

        int index = item[AValue].indexOf(RegExp(AMark, caseSensitive: false));

        String pMarkedString = item[AValue].substring(index, index + AMark.length);

        pHtmlElement = pHtmlElement.replaceAll(RegExp(pMarkedString, caseSensitive: false), "<span>$pMarkedString</span>");

        var pElement = HTMLSpanElement()..innerText = item[AValue];

        pElement.style.color = "black";
        pElement.style.fontWeight = "bold";
        pElement.style.userSelect = "none";
        pElement.style.cursor = "default";

        (pElement.children[0] as HTMLElement).style.color = "rgb(4, 94, 191)";
        (pElement.children[0] as HTMLElement).style.fontWeight = "bold";
        (pElement.children[0] as HTMLElement).style.userSelect = "none";
        (pElement.children[0] as HTMLElement).style.cursor = "default";

        divItem.appendChild(pElement);
      } catch (_) {
        divItem.text = item[AValue];
        divItem.style.fontWeight = "bold";
      }
    }

    divItem.onClick.listen((Event event) {
      for (var i = 0; i <= document.querySelectorAll(".divItem").length - 1; i++) {
        (document.querySelectorAll(".divItem").item(i) as HTMLElement).style.background = "white";
        (document.querySelectorAll(".divItem").item(i) as HTMLElement).classList.remove('selected');
      }

      divItem.style.background = "rgb(212, 220, 250)";
      divItem.classList.add("selected");
    });

    divItemContainer.appendChild(divItem);
  }

  if (ASelected != null && !pFound) {
    divItemFirst?.style.background = "rgb(212, 220, 250)";
    divItemFirst?.classList.add("selected");
  }

  var divButtonContainer = document.createDiv()
    ..style.borderTopStyle = "solid"
    ..style.borderColor = "black"
    ..style.borderWidth = "1px";

  var btnOK = document.createButton()
    ..text = "Aceptar"
    ..style.float = "right"
    ..style.marginTop = "20px"
    ..style.marginRight = "5px";
  btnOK.onClick.listen((_) {
    var divItem = document.querySelector(".selected") as HTMLDivElement;

    var pMapResult = <String, String>{};
    pMapResult[AKey] = divItem.attributes.getNamedItem("data-value")!.value;
    pMapResult[AValue] = divItem.innerText;

    fComplete(pMapResult);
  });

  var btnCancel = document.createButton()
    ..text = "Cancelar"
    ..style.float = "right"
    ..style.marginTop = "20px"
    ..style.marginRight = "5px";
  btnCancel.onClick.listen((_) {
    fComplete(null);
  });

  divButtonContainer.appendChild(btnOK);
  divButtonContainer.appendChild(btnCancel);

  m1.appendChild(divButtonContainer);

  if ((AList as List<dynamic>).isNotEmpty) {
    (document.querySelector("#item0") as HTMLDivElement).focus();
  }

  dlg.showModal();

  if (divItemTmp != null) {
    print('into view');
    print(divItemTmp);
    print(divItemTmp.id);
    divItemTmp.scrollIntoView();
    divItemTmp.focus();
  } else {
    divButtonContainer.scrollIntoView();
  }
  return pResult.future;
}

Future<TDialogResult> showDialogWeb(String AText, String ATitle, TDialogType ADialogType, TDialogButtons ADialogButtons) {
  var pContainerId = 'showDialogMessage';

  var pResult = Completer<TDialogResult>();

  var dlg = document.createDialog();
  dlg.style.borderWidth = '0px';
  dlg.style.backgroundColor = 'transparent';
  document.body!.appendChild(dlg);
  var m1 = _getWindowDivWeb('400px', '200px');
  dlg.appendChild(m1);

  var divItemTitle = _getTitleDivWeb(ATitle);
  m1.appendChild(divItemTitle);

  var divItemContainer = document.createDiv();
  divItemContainer.style.height = '100px';
  divItemContainer.style.overflowY = 'auto';
  m1.appendChild(divItemContainer);

  Function? fComplete(TDialogResult AResult) {
    dlg.close();
    dlg.remove();
    pResult.complete(AResult);
    return null;
  }

  dlg.onKeyDown.listen((KeyboardEvent event) {
    if (document.querySelector('#$pContainerId') == null) {
      return;
    }

    var code = event.which;

    if (code == 27) {
      if (ADialogButtons == TDialogButtons.OK_CANCEL) {
        fComplete(TDialogResult.CANCEL);
      } else if (ADialogButtons == TDialogButtons.YES_NO) {
        fComplete(TDialogResult.NO);
      } else {
        fComplete(TDialogResult.OK);
      }

      event.preventDefault();
      event.stopPropagation();
    }
  });

  var divMessageContainer = document.createDiv();

  var pSymbolImage = document.createImage();

  switch (ADialogType) {
    case TDialogType.QUESTION:
      pSymbolImage.src = _questionImageBase64;
      break;

    case TDialogType.ERROR:
      pSymbolImage.src = _errorImageBase64;
      break;

    case TDialogType.WARNING:
      pSymbolImage.src = _warningImageBase64;
      break;

    case TDialogType.INFO:
      pSymbolImage.src = _infoImageBase64;
      break;
  }

  pSymbolImage.style.width = '80px';
  pSymbolImage.style.height = '80px';
  pSymbolImage.style.float = 'left';
  pSymbolImage.style.marginLeft = '10px';
  pSymbolImage.style.marginTop = '10px';

  divItemContainer.appendChild(pSymbolImage);

  var pDialogText = document.createDiv();

  pDialogText.style.paddingTop = '13px';
  pDialogText.style.marginTop = '10px';
  pDialogText.style.marginLeft = '10px';
  pDialogText.style.height = '20px';
  pDialogText.style.padding = '5px';
  pDialogText.style.maxWidth = '240px';
  pDialogText.style.float = 'left';
  pDialogText.text = AText;

  divItemContainer.appendChild(pDialogText);
  divItemContainer.appendChild(divMessageContainer);

  var divButtonContainer = document.createDiv()
    ..style.borderTopStyle = 'solid'
    ..style.borderColor = 'silver'
    ..style.borderWidth = '1px'
    ..style.paddingRight = '30px';

  late HTMLButtonElement btnOK;
  late HTMLButtonElement btnCancel;
  late HTMLButtonElement btnYES;
  late HTMLButtonElement btnNO;

  if (ADialogButtons == TDialogButtons.OK || ADialogButtons == TDialogButtons.OK_CANCEL) {
    btnOK = document.createButton()
      ..innerText = 'Aceptar'
      ..style.float = 'right'
      ..style.marginTop = '20px'
      ..style.marginRight = '5px';
    btnOK.onClick.listen((_) {
      fComplete(TDialogResult.OK);
    });

    divButtonContainer.appendChild(btnOK);
  }

  if (ADialogButtons == TDialogButtons.OK_CANCEL) {
    // ignore: unsafe_html
    btnCancel = document.createButton()
      ..innerText = 'Cancelar'
      ..style.float = 'right'
      ..style.marginTop = '20px'
      ..style.marginRight = '5px';
    btnCancel.onClick.listen((_) {
      fComplete(TDialogResult.CANCEL);
    });

    divButtonContainer.appendChild(btnCancel);
  }

  if (ADialogButtons == TDialogButtons.YES_NO) {
    // ignore: unsafe_html
    btnYES = document.createButton()
      ..innerText = 'Yes'
      ..style.float = 'right'
      ..style.marginTop = '20px'
      ..style.marginRight = '5px';
    btnYES.onClick.listen((_) {
      fComplete(TDialogResult.YES);
    });

    // ignore: unsafe_html
    btnNO = document.createButton()
      ..innerText = 'No'
      ..style.float = 'right'
      ..style.marginTop = '20px'
      ..style.marginRight = '5px';
    btnNO.onClick.listen((_) {
      fComplete(TDialogResult.NO);
    });

    divButtonContainer.appendChild(btnYES);
    divButtonContainer.appendChild(btnNO);
  }

  m1.appendChild(divButtonContainer);

  if (ADialogButtons == TDialogButtons.YES_NO) {
    btnYES.focus();
  } else {
    btnOK.focus();
  }

  document.body!.appendChild(dlg);
  dlg.showModal();
  return pResult.future;
}

Future<String?> inputText(String AText, String ATitle, {bool Password = false}) {
  var pResult = Completer<String>();

  var dlg = document.createDialog();
  dlg.style.borderWidth = '0px';
  dlg.style.backgroundColor = 'transparent';
  document.body?.appendChild(dlg);

  var m1 = _getWindowDivWeb("400px", "200px");
  dlg.appendChild(m1);

  var divItemTitle = _getTitleDivWeb(ATitle);
  m1.appendChild(divItemTitle);

  var divItemContainer = document.createDiv();
  divItemContainer.style.height = "100px";
  divItemContainer.style.overflowY = "auto";
  m1.appendChild(divItemContainer);

  Function? fComplete(String? AResult) {
    pResult.complete(AResult);
    dlg.close();
    dlg.remove();
    return null;
  }

  dlg.onKeyDown.listen((KeyboardEvent event) {
    var code = 0;

    try
    {
      code = event.keyCode;
    } catch (_) {
      return;
    }

    code = event.which;

    if (code == 13) {
      var inpText = document.querySelector("#inpText") as HTMLInputElement;

      fComplete(inpText.value);
      event.preventDefault();
      event.stopPropagation();
    }

    if (code == 27) {
      fComplete(null);
      event.preventDefault();
      event.stopPropagation();
    }
  });

  var inpText = document.createInput()..id = "inpText";

  if (Password) {
    inpText.type = 'password';
  }

  inpText.style.paddingTop = "13px";
  inpText.style.marginTop = "30px";
  inpText.style.marginLeft = "50px";
  inpText.style.height = "20px";
  inpText.style.padding = "5px";
  inpText.style.width = "300px";
  inpText.value = AText;

  divItemContainer.appendChild(inpText);

  var divButtonContainer = document.createDiv()
    ..style.borderTopStyle = "solid"
    ..style.borderColor = "silver"
    ..style.borderWidth = "1px"
    ..style.paddingRight = "30px";

  var btnOK = document.createButton()
    ..text = 'Aceptar'
    ..style.float = "right"
    ..style.marginTop = "20px"
    ..style.marginRight = "5px";
  btnOK.onClick.listen((_) {
    fComplete(inpText.value);
  });

  var btnCancel = document.createButton()
    ..text = 'Cancelar'
    ..style.float = "right"
    ..style.marginTop = "20px"
    ..style.marginRight = "5px";
  btnCancel.onClick.listen((_) {
    fComplete(null);
  });

  divButtonContainer.appendChild(btnOK);
  divButtonContainer.appendChild(btnCancel);

  m1.appendChild(divButtonContainer);

  dlg.showModal();
  inpText.focus();
  inpText.select();

  return pResult.future;
}

HTMLDialogElement showModal(String AId) {
  var dlg = document.createElement('DIALOG') as HTMLDialogElement;
  var pModal = document.querySelector(AId) as HTMLDivElement;
  dlg.append(pModal);
  pModal.style.display = 'block';
  document.body?.appendChild(dlg);
  dlg.showModal();
  return dlg;
}

void cierraModal(String AId) {
  HTMLDivElement pModal = document.querySelector(AId) as HTMLDivElement;
  HTMLDialogElement pModalDialog = (pModal.parentNode as HTMLDialogElement);
  pModalDialog.close();
  pModal.style.display = 'none';
  document.body?.append(pModal);
  pModalDialog.remove();
}
