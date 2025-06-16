extends Node

var MenuMakerHelper = preload("res://MenuMakerHelper.gd").new()

func createNavButtons(pageNumber, pageCount, displayPageMethod, posY, container):
	if pageNumber > 0:
		var backBtn = MenuMakerHelper.addTextButton("<--", 12, displayPageMethod.bind(pageNumber-1), 90, container)
		backBtn.position = Vector2(90, posY)
		
	if pageNumber < pageCount - 1:	
		var nextBtn = MenuMakerHelper.addTextButton("-->", 12, displayPageMethod.bind(pageNumber+1), 90, container)
		nextBtn.position = Vector2(680, posY)
		
	if pageNumber > 0:
		var homeBtn = MenuMakerHelper.addTextButton("Home", 12, displayPageMethod.bind(0), 90, container)
		homeBtn.position = Vector2(20, posY)

func createPageNumber(pageNumber, pageCount, posY, container):
	var pageLabel = Label.new()
	pageLabel.text = "Page %d/%d" % [pageNumber + 1, pageCount]
	pageLabel.position = Vector2(320, posY)
	container.add_child(pageLabel)
