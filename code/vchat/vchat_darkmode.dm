/client/proc/toggle_darkmode(var/enabled)
	//Shipped in the form of a URL, so we don't have actual bools
	if(enabled == "false")
		enabled = FALSE
	else if(enabled == "true")
		enabled = TRUE

	if(enabled)
		activate_darkmode()
	else
		deactivate_darkmode()


/client/proc/activate_darkmode()
	///// BUTTONS /////
	/* Rpane */
	winset(src, "rpane.textb", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.infob", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.wikib", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.forumb", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.rulesb", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "rpane.githubb", "background-color=#40628a;text-color=#FFFFFF")
	/* Mainwindow */
	winset(src, "mainwindow.saybutton", "background-color=#40628a;text-color=#FFFFFF")
	winset(src, "mainwindow.mebutton", "background-color=#40628a;text-color=#FFFFFF")
	///// UI ELEMENTS /////
	/* Mainwindow */
	winset(src, "mainwindow", "background-color=#272727")
	winset(src, "mainwindow.mainvsplit", "background-color=#272727")
	winset(src, "mainwindow.tooltip", "background-color=#272727")
	/* Rpane */
	winset(src, "rpane", "background-color=#272727")
	winset(src, "rpane.rpanewindow", "background-color=#272727")
	/* Browserwindow */
	//winset(src, "browserwindow", "background-color=#272727")
	//winset(src, "browserwindow.browser", "background-color=#272727")
	/* Infowindow */
	winset(src, "infowindow", "background-color=#272727;text-color=#FFFFFF")
	winset(src, "infowindow.info", "background-color=#272727;text-color=#FFFFFF;highlight-color=#009900;tab-text-color=#FFFFFF;tab-background-color=#272727")

/client/proc/deactivate_darkmode()
	///// BUTTONS /////
	/* Rpane */
	winset(src, "rpane.textb", "background-color=none;text-color=#000000")
	winset(src, "rpane.infob", "background-color=none;text-color=#000000")
	winset(src, "rpane.wikib", "background-color=none;text-color=#000000")
	winset(src, "rpane.forumb", "background-color=none;text-color=#000000")
	winset(src, "rpane.rulesb", "background-color=none;text-color=#000000")
	winset(src, "rpane.githubb", "background-color=none;text-color=#000000")
	/* Mainwindow */
	winset(src, "mainwindow.saybutton", "background-color=none;text-color=#000000")
	winset(src, "mainwindow.mebutton", "background-color=none;text-color=#000000")
	///// UI ELEMENTS /////
	/* Mainwindow */
	winset(src, "mainwindow", "background-color=none")
	winset(src, "mainwindow.mainvsplit", "background-color=none")
	winset(src, "mainwindow.tooltip", "background-color=none")
	/* Rpane */
	winset(src, "rpane", "background-color=none")
	winset(src, "rpane.rpanewindow", "background-color=none")
	/* Browserwindow */
	winset(src, "browserwindow", "background-color=none")
	winset(src, "browserwindow.browser", "background-color=none")
	/* Infowindow */
	winset(src, "infowindow", "background-color=none;text-color=#000000")
	winset(src, "infowindow.info", "background-color=none;text-color=#000000;highlight-color=#007700;tab-text-color=#000000;tab-background-color=none")
