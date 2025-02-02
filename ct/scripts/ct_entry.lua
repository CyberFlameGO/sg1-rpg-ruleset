-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- Set the displays to what should be shown
	setTargetingVisible();
	setAttributesVisible();
	setActiveVisible();
	setSpacingVisible();
	setEffectsVisible();

	-- Acquire token reference, if any
	linkToken();
	
	-- Set up the PC links
	onLinkChanged();
	onFactionChanged();
	onHealthChanged();
	
	-- Register the deletion menu item for the host
	registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
end

function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		nonid_name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		nonid_name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		delete();
	end
end

function delete()
	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Remember node name
	local sNode = node.getPath();
	
	-- Clear any effects first, so that saves aren't triggered when initiative advanced
	effects.reset(false);

	-- Move to the next actor, if this CT entry is active
	if DB.getValue(node, "active", 0) == 1 then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	local cList = windowlist;
	node.delete();

	-- Update list information (global subsection toggles, targeting)
	cList.onVisibilityToggle();
	cList.onEntrySectionToggle();
end

function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
	onIDChanged();
end

function onHealthChanged()
	local rActor = ActorManager.resolveActor(getDatabaseNode());
	local _,sStatus,sColor = ActorHealthManager.getHealthInfo(rActor);

	wounds.setColor(sColor);
	status.setValue(sStatus);

	local sClass,_ = link.getValue();
	if sClass ~= "charsheet" then
		idelete.setVisibility(ActorHealthManager.isDyingOrDeadStatus(sStatus));
	end
end

function onIDChanged()
	local nodeRecord = getDatabaseNode();
	local sClass = DB.getValue(nodeRecord, "link", "", "");
	if sClass == "npc" then
		local bID = LibraryData.getIDState("npc", nodeRecord, true);
		name.setVisible(bID);
		nonid_name.setVisible(not bID);
		isidentified.setVisible(true);
	else
		name.setVisible(true);
		nonid_name.setVisible(false);
		isidentified.setVisible(false);
	end
end

function onFactionChanged()
	-- Update the entry frame
	updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end
end

function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end

function onActiveChanged()
	setActiveVisible();
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		senses.setLink(nodeChar.createChild("senses", "string"), true);

		hptotal.setLink(nodeChar.createChild("hp.total", "number"));
		hptemp.setLink(nodeChar.createChild("hp.temporary", "number"));
		wounds.setLink(nodeChar.createChild("hp.wounds", "number"));
		deathsavesuccess.setLink(nodeChar.createChild("hp.deathsavesuccess", "number"));
		deathsavefail.setLink(nodeChar.createChild("hp.deathsavefail", "number"));

		type.setLink(nodeChar.createChild("race", "string"));
		size.setLink(nodeChar.createChild("size", "string"));
		alignment.setLink(nodeChar.createChild("alignment", "string"));
		
		strength.setLink(nodeChar.createChild("abilities.strength.score", "number"), true);
		dexterity.setLink(nodeChar.createChild("abilities.dexterity.score", "number"), true);
		constitution.setLink(nodeChar.createChild("abilities.constitution.score", "number"), true);
		intelligence.setLink(nodeChar.createChild("abilities.intelligence.score", "number"), true);
		wisdom.setLink(nodeChar.createChild("abilities.wisdom.score", "number"), true);
		charisma.setLink(nodeChar.createChild("abilities.charisma.score", "number"), true);

		init.setLink(nodeChar.createChild("initiative.total", "number"), true);
		ac.setLink(nodeChar.createChild("defenses.ac.total", "number"), true);
		speed.setLink(nodeChar.createChild("speed.total", "number"), true);
	end
end

--
-- SECTION VISIBILITY FUNCTIONS
--

function setTargetingVisible()
	local v = false;
	if activatetargeting.getValue() == 1 then
		v = true;
	end

	targetingicon.setVisible(v);
	
	sub_targeting.setVisible(v);
	
	frame_targeting.setVisible(v);

	target_summary.onTargetsChanged();
end

function setAttributesVisible()
	local v = false;
	if activateattributes.getValue() == 1 then
		v = true;
	end
	
	attributesicon.setVisible(v);

	strength.setVisible(v);
	strength_label.setVisible(v);
	dexterity.setVisible(v);
	dexterity_label.setVisible(v);
	constitution.setVisible(v);
	constitution_label.setVisible(v);
	intelligence.setVisible(v);
	intelligence_label.setVisible(v);
	wisdom.setVisible(v);
	wisdom_label.setVisible(v);
	charisma.setVisible(v);
	charisma_label.setVisible(v);
	
	spacer_attribute.setVisible(v);
	
	frame_attributes.setVisible(v);
end

function setActiveVisible()
	local v = false;
	if activateactive.getValue() == 1 then
		v = true;
	end

	local sClass, sRecord = link.getValue();
	local bNPC = (sClass ~= "charsheet");
	if bNPC and active.getValue() == 1 then
		v = true;
	end
	
	activeicon.setVisible(v);

	reaction.setVisible(v);
	reaction_label.setVisible(v);
	init.setVisible(v);
	initlabel.setVisible(v);
	ac.setVisible(v);
	aclabel.setVisible(v);
	speed.setVisible(v);
	speedlabel.setVisible(v);
	
	spacer_action.setVisible(v);
	
	if bNPC and traits.getWindowCount() > 0 then
		traits.setVisible(v);
		traits_label.setVisible(v);
	else
		traits.setVisible(false);
		traits_label.setVisible(false);
	end

	if bNPC then
		actions.setVisible(v);
		actions_label.setVisible(v);
		actions_emptyadd.update();
	else
		actions.setVisible(false);
		actions_label.setVisible(false);
		actions_emptyadd.setVisible(false);
	end
	
	if bNPC and bonusactions.getWindowCount() > 0 then
		bonusactions.setVisible(v);
		bonusactions_label.setVisible(v);
	else
		bonusactions.setVisible(false);
		bonusactions_label.setVisible(false);
	end
	
	if bNPC and reactions.getWindowCount() > 0 then
		reactions.setVisible(v);
		reactions_label.setVisible(v);
	else
		reactions.setVisible(false);
		reactions_label.setVisible(false);
	end

	if bNPC and legendaryactions.getWindowCount() > 0 then
		legendaryactions.setVisible(v);
		legendaryactions_label.setVisible(v);
	else
		legendaryactions.setVisible(false);
		legendaryactions_label.setVisible(false);
	end

	if bNPC and lairactions.getWindowCount() > 0 then
		lairactions.setVisible(v);
		lairactions_label.setVisible(v);
	else
		lairactions.setVisible(false);
		lairactions_label.setVisible(false);
	end

	if bNPC and innatespells.getWindowCount() > 0 then
		innatespells.setVisible(v);
		innatespells_label.setVisible(v);
	else
		innatespells.setVisible(false);
		innatespells_label.setVisible(false);
	end

	if bNPC and spells.getWindowCount() > 0 then
		spellslots.setVisible(v);
		spells.setVisible(v);
		spells_label.setVisible(v);
	else
		spells.setVisible(false);
		spells_label.setVisible(false);
	end

	spacer_action2.setVisible(v);
	
	frame_active.setVisible(v);
end

function setSpacingVisible(v)
	local v = false;
	if activatespacing.getValue() == 1 then
		v = true;
	end

	spacingicon.setVisible(v);
	
	space.setVisible(v);
	spacelabel.setVisible(v);
	reach.setVisible(v);
	reachlabel.setVisible(v);
	
	spacer_space.setVisible(v);

	frame_spacing.setVisible(v);
end

function setEffectsVisible(v)
	local v = false;
	if activateeffects.getValue() == 1 then
		v = true;
	end
	
	effecticon.setVisible(v);
	
	effects.setVisible(v);
	effects_iadd.setVisible(v);
	for _,w in pairs(effects.getWindows()) do
		w.idelete.setValue(0);
	end
	
	frame_effects.setVisible(v);

	effect_summary.onEffectsChanged();
end
