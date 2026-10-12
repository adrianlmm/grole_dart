library ModalP;

import "dart:html";

void cierra_modal(String AContainer) {
  
  DivElement mc = querySelector("#${AContainer}");
  mc.style.display = "none";  
  
}

void modal(String AContainer) {
    DivElement m1 = querySelector("#${AContainer}-body");
    DivElement mc = querySelector("#${AContainer}");
    
    mc.style.display = "block";
    
    m1.style.position = "relative";
    m1.style.backgroundColor = "white";
    m1.style.borderColor = "  gray";
    m1.style.borderWidth = "1px";
    m1.style.borderStyle = "solid";
    
    m1.style.top = "0px";
    m1.style.zIndex = "9999";
    m1.style.padding = "5px";
    m1.style.boxShadow = "10px 10px 5px #888888";
    m1.style.overflowY = "auto";
    
    
    mc.style.backgroundColor = "rgba(190, 190, 190, 0.5)";
    mc.style.opacity  = "50%";
    mc.style.zIndex   = "9998";
    mc.style.width    = "100%";
    mc.style.height   = "100%";
    mc.style.position = "fixed";
    mc.style.margin   = "0px";
    mc.style.top      = "0px";
    
    var sw = m1.scrollWidth / 2;
    var sh = m1.scrollHeight / 2;
    
    var margin  = (window.innerWidth / 2)  - sw;
    var top     = 100;
    
    m1.style.marginLeft = "${margin}px";
    m1.style.marginTop  = "${top}px";
}