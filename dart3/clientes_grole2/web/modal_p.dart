library ModalP;

import "dart:html";

void cierra_modal(String AContainer) {
    DivElement mc = querySelector("#${AContainer}");
    mc.style.display = "none";
}

void modal(String AContainer) {
    DivElement m1 = querySelector("#${AContainer}-body");
    DivElement mc = querySelector("#${AContainer}");
    
    m1.style.position = "block";
    m1.style.backgroundColor = "white";
    m1.style.borderColor = "gray";
    m1.style.borderWidth = "1px";
    m1.style.borderStyle = "solid";
    
    m1.style.top = "0px";
    m1.style.zIndex = "9999";
    m1.style.padding = "5px";
    m1.style.boxShadow = "5px 5px 3px #888888";
    
    mc.style.backgroundColor = "rgba(190, 190, 190, 0.5)";
    mc.style.opacity  = "50%";
    mc.style.zIndex   = "9998";
    mc.style.width    = "100%";
    mc.style.height   = "5000px";
    mc.style.position = "absolute";
    mc.style.margin   = "0px";
    mc.style.marginLeft   = "-100px";
    mc.style.top      = "0px";
    
    mc.style.display = "block";
    
    var sw = m1.scrollWidth / 2;
    var sh = m1.scrollHeight / 2;
    var top     = 50;
    
    var windowHeight = window.innerHeight;
    var mtop = ((windowHeight / 2) - sh) - 25;
    
    m1.style.margin = "0 auto";
    m1.style.marginTop  = "${mtop}px";
}