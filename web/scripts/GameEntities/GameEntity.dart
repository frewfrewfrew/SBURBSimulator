import "dart:html";
import "dart:math" as Math;
import "../SBURBSim.dart";

enum ProphecyState {
    NONE,
    ACTIVE,
    FULLFILLED
}

//fully replacing old GameEntity that was also an unholy combo of strife engine
//not abstract, COULD spawn just a generic game entity.
class GameEntity extends Object with StatOwner   {

    int playerKillCount = 0;

    int npcKillCount = 0;
    bool usedMiles = false;
    int landKillCount  = 0;
    int moonKillCount  = 0;
    bool everCrowned = false;


    //availibility set to false by scenes
    bool available = true;
    //scenes are no longer singletons owned by the session. except for the reckoning and aftermath
    List<Scene> scenes = new List<Scene>();
    List<Scene> scenesToAdd = new List<Scene>();

    //mostly for npcs, might not be the best way to do it but it's what i'm gonna do for now.
    //x starts flipping out about TAB soda
    List<String> distractions = new List<String>();
    //AW wrote up a bunch of these for carapaces
    String description = "";

    //why are they pestering Jack?
    List<String> bureaucraticBullshit = new List<String>();

    //not there yet, but putting down foundation.
    bool bigBad = false;
    //players activate when they enter session, npcs activate when they encounter a player.
    bool active  = false;

    //if you become a companion, they are your party leader.
    GameEntity partyLeader;
    static int _nextID = 0;
    Specibus specibus;
    Sylladex sylladex = null;
    //1/16/18 let's fucking do this. npc update go. mostly npcs but can be brain ghosts and robots, too.
    List<GameEntity> _companions = new List<GameEntity>();

    ProphecyState prophecy = ProphecyState.NONE; //doom players can give this which nerfs their stats but ALSO gives them a huge boost when they die
    //TODO figure out how i want tier 2 sprites to work. prototyping with a carapace and then a  player and then god tiering should result in a god tier Player that can use the Royalty's Items.

    /// can NEVER be null, but I expect this to be replaced.
    Session session = PotentialSprite.defaultSession; //don't make a new one just use default, don't care what it is gonna override it if it's important.

    //TODO replace 'minLuck' with 'destiny'
    String name = "";
    //TODO the next few stats are for sprites but since ANY living thing can become a sprite...

    String helpPhrase = "provides the requisite amount of gigglesnort hideytalk to be juuuust barely helpful. ";
    num helpfulness = 0;
    bool armless = false;
    bool disaster = false;
    bool lusus = false; //HAVE to be vars or can't inherit through prototyping.
    bool player = false;
    bool illegal = false; //maybe AR won't help players with ILLEGAL sprites?
    //
    String fontColor = "#000000";
    bool ghost = false; //if you are ghost, you are rendered spoopy style
    bool brainGhost = false;

    num grist = 100; //everything has it.
    bool dead = false;
    String causeOfDrain = null; //if it's ever not null they will be sideways
    bool exiled = false;
    List<GhostPact> ghostPacts = <GhostPact>[]; //list of two element array [Ghost, enablingAspect]
    bool corrupted = false; //players are corrupted at level 4. will be easier than always checking grimDark level
    List<Fraymotif> fraymotifs = <Fraymotif>[];
    bool usedFraymotifThisTurn = false;
    List<Relationship> relationships = <Relationship>[]; //not to be confused with the RELATIONSHIPS stat which is the value of all relationships.
    //Map<String, num> permaBuffs = <String, num>{ "MANGRIT": 0}; //is an object so it looks like a player with stats.  for things like manGrit which are permanent buffs to power (because modding power directly is confusing since it's also 'level')
    num renderingType = 0; //0 means default for this sim.
    List<AssociatedStat> associatedStats = <AssociatedStat>[]; //most players will have a 2x, a 1x and a -1x stat.
    //String spriteCanvasID = null; //part of new rendering engine. deprecated 1/24/18 in favor of using a canvas directly
    CanvasElement canvas;

    num id;
    bool doomed = false; //if you are doomed, no matter what you are, you are likely to die.
    List<Player> doomedTimeClones = <Player>[]; //help fight the final boss(es).
    String causeOfDeath = ""; //fill in every time you die. only matters if you're dead at end

    //npc traits: violent, lucky, charming, cunning

    String get initials {
        RegExp exp = new RegExp(r"""\b(\w)|[A-Z]""", multiLine: true);
        String ret =  joinMatches(exp.allMatches(name)).toUpperCase();
        if(ret == "JN") return "SS"; //fuck you, that's why. Nah. I'm sorry. It's because Jack Noir needs to have the same initails as his Crowned or Exiled self.
        return ret;
    }

    bool get violent {
        if(getStat(Stats.SANITY) <0 && getStat(Stats.RELATIONSHIPS)<0) return true;
        return false;
    }

    bool get lucky {
        if(getStat(Stats.MAX_LUCK) >0 && getStat(Stats.MIN_LUCK) >0) return true;
        return false;
    }

    bool get charming {
        if(getStat(Stats.ALCHEMY) >0 && getStat(Stats.RELATIONSHIPS)>0) return true;
        return false;
    }

    bool get cunning {
        if(getStat(Stats.FREE_WILL) >0 && getStat(Stats.MOBILITY)>0) return true;
        return false;
    }



    //useful for initing npcs, probably won't use for players.

    //hateful and crazy
    void makeViolent([int base = 100]) {
        setStat(Stats.SANITY, -1* base);
        setStat(Stats.RELATIONSHIPS, -1* base);
    }

    //lucky
    void makeLucky([int base = 100]) {
        setStat(Stats.MIN_LUCK, base);
        setStat(Stats.MAX_LUCK, base);
    }

    //creative and friendly
    void makeCharming([int base = 100]) {
        setStat(Stats.ALCHEMY, base);
        setStat(Stats.RELATIONSHIPS, base);
    }

    //determined and fast
    void makeCunning([int base = 100]) {
        setStat(Stats.FREE_WILL, base);
        setStat(Stats.MOBILITY, base);
    }

    //just returns first, hoarding them does nothing.
    MagicalItem get crowned

        {
            for(Item item in sylladex) {
                if(item is Ring || item is Scepter) {
                    return item;
                }
            }
        }

    Ring get ring

    {
        for(Item item in sylladex) {
            if(item is Ring) {
                return item;
            }
        }
    }

    Scepter get scepter

    {
        for(Item item in sylladex) {
            if(item is Scepter) {
                return item;
            }
        }
    }

    bool get alliedToPlayers {

        //big bads are never allies
        if(bigBad) return false;
        if(partyLeader != null && partyLeader.bigBad) return false;

        //lots of ways to be on player's side
        if(this is Sprite) return true; //you're a guide
        if(this is Player) return true; //you're a player
        //you're prospit
        if(this is Carapace && (this as Carapace).type == Carapace.PROSPIT) return true;
        //if you're a companion you're an ally.
        if(partyLeader != null && (partyLeader is Player)) return true;

        //default
        return false;
    }

    //my scenes can trigger behavior in other things that makes them unable to do their own scenes.
    //this is intended. probably.
    void processScenes() {
      // ;
        //can do as many as you want, so long as you haven't been taken out of availibility
        for(Scene s in scenes) {
            s.gameEntity = this;
            // ;
            //if one scene makes you unavailable no future scenes
            if (this.available && s.trigger(session.getReadOnlyAvailablePlayers())) {
                //session.scenesTriggered.add(s);
                this.session.numScenes ++;
                s.renderContent(this.session.newScene(s.runtimeType.toString()));
            }
        }

        //otherwise will get conconrrent modification error. put at front, new things are important and shiny
       // if(scenesToAdd.isNotEmpty) print("TEST RECKONING: adding ${scenesToAdd.length} scenes to $this");
        scenes.insertAll(0,scenesToAdd);
        scenesToAdd.clear();
    }


    List<GameEntity> get companionsCopy {
        //don't want there to be a way to get companions directly
        //cuz then i might add and remove without going through methods.
        return new List<GameEntity>.from(_companions);
    }

    void addCompanion(GameEntity companion) {
        if(companion.partyLeader != this && companion.partyLeader != null) companion.partyLeader.removeCompanion(companion);
        companion.partyLeader = this;
        for(Scene s in companion.scenes) {
            if(s is MailSideQuest) {
                scenesToAdd.insert(0, new MailSideQuest(session));
            }
        }
        _companions.add(companion);
    }

    void removeCompanion(GameEntity companion) {
        companion.partyLeader = null;
        _companions.remove(companion);
    }


    GameEntity(this.name, this.session) {
        this.initStatHolder();
        id = GameEntity.generateID();
        sylladex = new Sylladex(this);
        //;
        //default non player thingy.
        this.specibus = SpecibusFactory.CLAWS;
        this.addBuff(new BuffSpecibus(this)); //programatic
        this.addBuff(new BuffLord(this)); //will only apply if you are a lord, but all have potential
       //crashes if(getStat(Stats.CURRENT_HEALTH) <= 0) setStat(Stats.CURRENT_HEALTH, 10);
        if(!(this is PotentialSprite) && session != null) session.npcHandler.allEntities.add(this);
    }

    Iterable<AssociatedStat> get associatedStatsFromAspect => associatedStats.where((AssociatedStat c) => c.isFromAspect);

    //otherwise ids won't be stable across yards/resets etc.
    static void resetNextIdTo(int val) {
        _nextID = val;
    }

    String get debugStatsRaw {
        String ret = "";
        for(Stat s in stats) {
            ret += "${s.name}: ${stats.getBase(s).round()},";
        }
        return ret;
    }

    String get debugStats {
        String ret = "";
        for(Stat s in stats) {
            ret += "${s.name}: ${getStat(s).round()},";
        }
        return ret;
    }

    Stat get highestStat {
        Stat ret = stats.first;
        for(Stat s in stats) {
            //stats.getBase lets you get raw value, not multiplieid
            if(s != Stats.CURRENT_HEALTH && getStat(s)/s.coefficient > getStat(ret)/ret.coefficient) {
                //;
                ret = s;
            }
        }
        return ret;
    }

    Stat get lowestStat {
        Stat ret = stats.first;
        for(Stat s in stats) {
            if(stats.getBase(s)/s.coefficient < stats.getBase(ret)/s.coefficient) ret = s;
        }
        return ret;
    }
    
    //TODO grab out every method that current gameEntity, Player and PlayerSnapshot are required to have.
    //TODO make sure Player's @overide them.

    @override
    String toString() {
        return this.title();
    }


    @override
    StatHolder createHolder() {
        return new ProphecyStatHolder<GameEntity>(this);
    }

    void addPrototyping(GameEntity object) {
        //session.logger.info("adding prototyping with fraymotifs ${object.fraymotifs} to ${this.fraymotifs} ");
        this.name = "${object.name}${this.name}"; //sprite becomes puppetsprite.
        this.fraymotifs.addAll(object.fraymotifs);
        if (object.fraymotifs.isEmpty) {
            Fraymotif f = new Fraymotif("${object.name}Sprite Beam!", 1);
            f.effects.add(new FraymotifEffect(Stats.POWER, 2, true)); //do damage
            f.effects.add(new FraymotifEffect(Stats.HEALTH, 1, true)); //heal
            f.desc = " An appropriately themed beam of light damages enemies and heals allies. ";
            this.fraymotifs.add(f);
        }
        this.corrupted = object.corrupted;
        if (this is Sprite && object is PotentialSprite) {
            Sprite s = this;
            PotentialSprite ps = object;
            s.helpfulness = ps.helpfulness; //completely overridden.
            s.helpPhrase = ps.helpPhrase;
            s.grist += ps.grist;
            s.lusus = ps.lusus;
            s.illegal = ps.illegal;
            s.player = ps.player;
        }
        for (Stat key in object.stats) {
            addStat(key, object.stats.getBase(key)); //add your stats to my stas.
        }
    }


    //handles cloning generic stuff important because it's how a PLayer becomes a GameEntity (such as a PLayerSprite)
    GameEntity clone () {
        GameEntity clonege = new GameEntity(name, session);
        copyStatsTo(clonege);
        return clonege;
    }

    void copyStatsTo(GameEntity clonege) {
        clonege.stats = this; // copies the stats via StatOwner's stats setter! (also buffs)
        clonege.fontColor = fontColor;
        clonege.ghost = ghost; //if you are ghost, you are rendered spoopy style
        clonege.grist = grist; //everything has it.
        clonege.dead = dead;
        clonege.ghostPacts = ghostPacts; //list of two element array [Ghost, enablingAspect]
        clonege.corrupted = corrupted; //players are corrupted at level 4. will be easier than always checking grimDark level
        clonege.fraymotifs = fraymotifs; //TODO should these be cloned, too?
        clonege.usedFraymotifThisTurn = usedFraymotifThisTurn;
        clonege.relationships = Relationship.cloneRelationshipsStopgap(relationships);
        clonege.renderingType = renderingType; //0 means default for this sim.
        clonege.associatedStats = associatedStats; //most players will have a 2x, a 1x and a -1x stat.
        clonege.doomed = doomed; //if you are doomed, no matter what you are, you are likely to die.
        clonege.doomedTimeClones = doomedTimeClones; //TODO should these be cloned? help fight the final boss(es).
        clonege.causeOfDeath = causeOfDeath; //fill in every time you die. only matters if you're dead at end
        clonege.sylladex = new Sylladex(sylladex.owner, sylladex.inventory);
    }

    //as each type of entity gets renderable, override this.
    bool renderable() {
        return false;
    }



    String checkDiedInAStrife(List<Team> enemyTeams) {
        if (getStat(Stats.CURRENT_HEALTH) <= 0) {
            //TODO check for jack, king
            GameEntity jack = Team.findJackInTeams(enemyTeams);
            GameEntity king = Team.findKingInTeams(enemyTeams);
            String causeOfDeath = "fighting in a strife against ${Team.getTeamsNames(enemyTeams)}";
            GameEntity killer;
            if (jack != null) {
                causeOfDeath = "after being shown too many stabs from Jack";
                killer = jack;
            } else if (king != null) {
                causeOfDeath = "fighting the Black King";
                killer = king;
            }

            if(killer == null) {
                Team enemies = enemyTeams[0];
                List<GameEntity> living = findLiving(enemies.members);
                living.sort(Stats.MOBILITY.sorter);
                if(living.isNotEmpty) killer = living[0]; //fastest member gets the loot
            }

            makeDead(causeOfDeath, killer);
            return "${htmlTitleHP()} has died. ";
        }
        return "";
    }

    void resetFraymotifs() {
        if(!session.mutator.rageField) {
            this.stats.onCombatEnd(); //rage just keeps going.
        }
        for (num i = 0; i < this.fraymotifs.length; i++) {
            this.fraymotifs[i].usable = true;
        }

        if(crowned != null) {
            crowned.resetFraymotifs();
        }
    }

    bool friendsWith(GameEntity other) {
        if(other == null) return false;
        Relationship r = getRelationshipWith(other);
        if(r == null) return false;
        return r.value > 0;
    }

    //any subclass can choose to do things differently. for now, this is default.
    //so yes, npcs can have ghost attacks.
    //this won't be called if I CAN'T take a turn because i participated in fraymotif
    void takeTurn(Element div, Team mySide, List<Team> enemyTeams) {
        if (usedFraymotifThisTurn) return; //already did an attack.
        if (mySide.absconded.contains(this)) return;
        //if still dead, return, can't do anything.
        if (dead) {
            reviveViaGhostPact(div);
            //whether it works or not, return. you can't revive AND do other stuff.
            return;
        }
        appendHtml(div, describeBuffs());
        if (checkAbscond(div, mySide, enemyTeams)) return; //nice abscond, bro

        //pick a team to target.  if cant find target, return
        Team targetTeam = pickATeamToTarget(enemyTeams);
        if (targetTeam == null) return; //nobody to fight.
        //pick a member of the team to extra target. ig player and light, even if corpse
        GameEntity target = pickATarget(targetTeam.getLivingMinusAbsconded());
        if (target == null) return; //nobody to attack.
        //try to use fraymotif
        if (!useFraymotif(div, mySide, target, targetTeam)) {
            aggrieve(div, target);
        }
        //last thing you do is die.
        mySide.checkForAPulse(div, enemyTeams);
        List<Team> allTeams = new List<Team>.from(enemyTeams);
        allTeams.add(mySide);
        for (Team team in enemyTeams) {
            team.checkForAPulse(div, team.getOtherTeams(allTeams));
        }
    }

    bool useFraymotif(Element div, Team mySide, GameEntity target, Team targetTeam) {
        List<GameEntity> living_enemies = targetTeam.getLivingMinusAbsconded();
        List<GameEntity> living_allies = mySide.getLivingMinusAbsconded();
        if (this.session.rand.nextDouble() > 0.5 && !(this is Player)) return false; //don't use them all at once, dunkass. unless you are a player. fraymotifs 4 lyfe
        List<Fraymotif> usableFraymotifs = this.session.fraymotifCreator.getUsableFraymotifs(this, living_allies, living_enemies);
        if (crowned != null) { //ring/scepter has fraymotifs, too.  (maybe shouldn't let humans get thefraymotifs but what the fuck ever. roxyc could do voidy shit.)
            usableFraymotifs.addAll(this.session.fraymotifCreator.getUsableFraymotifsMagicalItem(crowned, living_allies, living_enemies));
        }
        if (usableFraymotifs.isEmpty) return false;
        num mine = getStat(Stats.SANITY);
        num theirs = Stats.SANITY.average(living_enemies);
        if (mine + 200 < theirs && this.session.rand.nextDouble() < 0.5) {
           // ////session.logger.info("Too insane to use fraymotifs: ${htmlTitleHP()} against ${target.htmlTitleHP()} Mine: $mine Theirs: $theirs in session: ${this.session.session_id}");
            appendHtml(div, " The ${htmlTitleHP()} wants to use a Fraymotif, but they are too crazy to focus. ");
            return false;
        }
        mine = getStat(Stats.FREE_WILL);
        theirs = Stats.FREE_WILL.average(living_enemies);
        if (mine + 200 < theirs && this.session.rand.nextDouble() < 0.5) {
            //////session.logger.info("Too controlled to use fraymotifs: ${htmlTitleHP()} against ${target.htmlTitleHP()} Mine: $mine Theirs: $theirs in session: ${this.session.session_id}");
            appendHtml(div, " The ${htmlTitleHP()} wants to use a Fraymotif, but Fate dictates otherwise. ");
            return false;
        }

        Fraymotif chosen = usableFraymotifs[0];
        for (num i = 0; i < usableFraymotifs.length; i++) {
            Fraymotif f = usableFraymotifs[i];
            if (f.tier > chosen.tier) {
                chosen = f; //more stronger is more better (refance)
            } else if (f.tier == chosen.tier && f.aspects.length > chosen.aspects.length) {
                chosen = f; //all else equal, prefer the one with more members.
            }
        }
        appendHtml(div, "<Br><br>${chosen.useFraymotif(this, living_allies, target, living_enemies)}<br><Br>");
        chosen.usable = false;
        return true;
    }

    bool checkAbscond(Element div, Team mySide, List<Team> enemies) {
        if (!mySide.canAbscond) return false; //can't abscond, bro
        if (doomed) return false; //accept your fate.
        List<GameEntity> whoINeedToProtect = mySide.getLivingMinusAbsconded();
        num reasonsToLeave = 0;
        num reasonsToStay = 2; //generally prefer to win fights.
        reasonsToStay += getFriendsFromList(whoINeedToProtect).length;
        List<Relationship> hearts = getHearts();
        List<Relationship> diamonds = getDiamonds();
        for (Relationship heart in hearts) {
            if (whoINeedToProtect.contains(heart.target)) reasonsToStay += 1;
        }

        for (Relationship diamond in diamonds) {
            if (whoINeedToProtect.contains(diamond.target)) reasonsToStay += 1;
        }
        reasonsToStay += getStat(Stats.POWER) / Team.getTeamsStatTotal(enemies, Stats.CURRENT_HEALTH); //i can take you.
        reasonsToLeave += Team.getTeamsStatTotal(enemies, Stats.POWER) /getStat(Stats.CURRENT_HEALTH); //you can take me.
        if (reasonsToLeave > reasonsToStay * 2) {
            addStat(Stats.SANITY, -10);
            flipOut("how terrifying ${Team.getTeamsNames(enemies)} were");
            if (getStat(Stats.POWER) > Team.getTeamsStatAverage(enemies, Stats.MOBILITY)) {
                //console.log(" player actually absconds: they had " + player.hp + " and enemy had " + enemy.getStat(Stats.POWER) + this.session.session_id)
                appendHtml(div, "<br><img src = 'images/sceneIcons/abscond_icon.png'> The ${htmlTitleHP()} absconds right the fuck out of this fight.");
                mySide.absconded.add(this);
                mySide.remainingPlayersHateYou(div, this);
                return true;
            } else {
                appendHtml(div, " The ${htmlTitleHP()} tries to absconds right the fuck out of this fight, but the ${Team.getTeamsNames(enemies)} blocks them. Can't abscond, bro. ");
                return false;
            }
        } else if (reasonsToLeave > reasonsToStay) {
            if (getStat(Stats.POWER) > Team.getTeamsStatAverage(enemies, Stats.MOBILITY)) {
                //console.log(" player actually absconds: " + this.session.session_id)
                appendHtml(div, "<br><img src = 'images/sceneIcons/abscond_icon.png'>  Shit. The ${htmlTitleHP()} doesn't know what to do. They don't want to die... They abscond. ");
                mySide.absconded.add(this);
                mySide.remainingPlayersHateYou(div, this);
                return true;
            } else {
                appendHtml(div, " Shit. The ${htmlTitleHP()} doesn't know what to do. They don't want to die... Before they can decide whether or not to abscond ${Team.getTeamsNames(enemies)} blocks their escape route. Can't abscond, bro. ");
                return false;
            }
        }
        return false;
    }

    void aggrieve(Element div, GameEntity defense) {
        GameEntity offense = this; //easier for now.
        String ret = "<br><Br> The ${offense.htmlTitleHP()} targets the ${defense.htmlTitleHP()} with their ${offense.specibus.fullName}. ";
        if(offense.specibus.traits.contains(ItemTraitFactory.CORRUPT)) {
            ret += " Uh. Wow. Should they be using that?";
            if(offense is Player) {
                Player p = offense as Player;
                p.corruptionLevelOther += 10; //no, they really shouldn't.
                session.logger.info("corrupt specibus for player ${p.title()}, it's a ${p.specibus.fullName}");
            }
        }
        if (defense.dead) ret = "$ret Apparently their corpse sure is distracting? How luuuuuuuucky for the remaining players!";
        appendHtml(div, ret);

        //luck dodge
        //alert("offense roll is: " + offenseRoll + " and defense roll is: " + defenseRoll);
        //////session.logger.info("gonna roll for luck.");
        if (defense.rollForLuck(Stats.MIN_LUCK) > offense.rollForLuck(Stats.MIN_LUCK) * 10 + 200) { //adding 10 to try to keep it happening constantly at low levels
            //////session.logger.info("Luck counter: ${defense.htmlTitleHP()} ${this.session.session_id}");
            appendHtml(div, "The attack backfires and causes unlucky damage. The ${defense.htmlTitleHP()} sure is lucky!!!!!!!!");
            offense.addStat(Stats.CURRENT_HEALTH, -1 * offense.getStat(Stats.POWER) / 10); //damaged by your own power.
            //this.processDeaths(div, offense, defense);
            return;
        } else if (defense.rollForLuck(Stats.MAX_LUCK) > offense.rollForLuck(Stats.MAX_LUCK) * 5 + 100) {
           // ////session.logger.info("Luck dodge: ${defense.htmlTitleHP()} ${this.session.session_id}");
            appendHtml(div, "The attack misses completely after an unlucky distraction.");
            return;
        }
        //mobility dodge
        int r = this.session.rand.nextIntRange(1, 100); //don't dodge EVERY time. oh god, infinite boss fights. on average, fumble a dodge every 4 turns.;
        if (defense.getStat(Stats.POWER) > offense.getStat(Stats.POWER) * 10 + 200 && r > 25) {
            //////session.logger.info("Mobility counter: ${defense.htmlTitleHP()} ${this.session.session_id}");
            ret = ("The ${offense.htmlTitleHP()} practically appears to be standing still as they clumsily lunge towards the ${defense.htmlTitleHP()}");
            if (defense.getStat(Stats.CURRENT_HEALTH) > 0) {
                ret = "$ret. They miss so hard the ${defense.htmlTitleHP()} has plenty of time to get a counterattack in.";
                offense.addStat(Stats.CURRENT_HEALTH, -1 * defense.getStat(Stats.POWER));
            } else {
                ret = "$ret. They miss pretty damn hard. ";
            }
            appendHtml(div, "$ret ");
            //this.processDeaths(div, offense, defense);

            return;
        } else if (defense.getStat(Stats.MOBILITY) > offense.getStat(Stats.MOBILITY) * 5 + 100 && r > 25) {
            //////session.logger.info("Mobility dodge: ${defense.htmlTitleHP()} ${this.session.session_id}");
            appendHtml(div, " The ${defense.htmlTitleHP()} dodges the attack completely. ");
            return;
        }
        //base damage
        num hit = Math.max(1,offense.getStat(Stats.POWER));
        num offenseRoll = offense.rollForLuck();
        num defenseRoll = defense.rollForLuck();
        //critical/glancing hit odds.
        if (defenseRoll > offenseRoll * 2) { //glancing blow.
            //////session.logger.info("Glancing Hit: " + this.session.session_id);
            hit = hit / 2;
            appendHtml(div, " The attack manages to not hit anything too vital. ");
        } else if (offenseRoll > defenseRoll * 2) {
            //////session.logger.info("Critical hit.");
            ////////session.logger.info("Critical Hit: " + this.session.session_id);
            hit = hit * 2;
            appendHtml(div, " Ouch. That's gonna leave a mark. ");
        } else {
            //////session.logger.info("a hit.");
            appendHtml(div, " A hit! ");
        }


        defense.addStat(Stats.CURRENT_HEALTH, -1 * hit);
        //this.processDeaths(div, offense, defense);
    }


    //currently only thing ghost pacts are good for post refactor.
    void reviveViaGhostPact(Element div) {
        List<GhostPact> undrainedPacts = removeDrainedGhostsFromPacts(ghostPacts);
        if (!undrainedPacts.isEmpty) {
            ////session.logger.info("using a pact to autorevive in session ${this.session.session_id}");
            Player source = undrainedPacts[0].ghost;
            source.causeOfDrain = name;
            String ret = " In the afterlife, the ${htmlTitleBasic()} reminds the ${source.htmlTitleBasic()} of their promise of aid. The ghost agrees to donate their life force to return the ${htmlTitleBasic()} to life ";
            if (this is Player) {
                Player me = this;
                if (me.godTier) ret = "$ret, but not before a lot of grumbling and arguing about how the pact shouldn't even be VALID anymore since the player is fucking GODTIER, they are going to revive fucking ANYWAY. But yeah, MAYBE it'd be judged HEROIC or some shit. Fine, they agree to go into a ghost coma or whatever. ";
            }
            ret = "${ret}It will be a while before the ghost recovers.";
            appendHtml(div, ret);
            Player myGhost = this.session.afterLife.findClosesToRealSelf(this);
            removeFromArray(myGhost, this.session.afterLife.ghosts);
            // CanvasElement canvas = drawReviveDead(div, this, source, undrainedPacts[0][1]);
            makeAlive();
            if (undrainedPacts[0].enablingAspect == Aspects.LIFE) {
                addStat(Stats.CURRENT_HEALTH, 100); //i won't let you die again.
            } else if (undrainedPacts[0].enablingAspect == Aspects.DOOM) {
                addStat(Stats.MIN_LUCK, 100); //you've fulfilled the prophecy. you are no longer doomed.
                div.appendHtml("The prophecy is fulfilled. ", treeSanitizer: NodeTreeSanitizer.trusted);
            }
        }
    }

    Team pickATeamToTarget(List<Team> team) {
        //TODO later add actual AI to this but for now, should only be one other team.
        return this.session.rand.pickFrom(team);
    }

    GameEntity pickATarget(List<GameEntity> targets) {
        if (targets.isEmpty) return null;
        if (targets.length == 1) return targets[0];
        targets.sort(Stats.MOBILITY.sorter); //as long as I always prefer new targets of equal juciness, will target slowest people preferentially.
        List<num> ratings = new List<num>();
        for (GameEntity t in targets) {
            num r = 0;
            if (t.getStat(Stats.CURRENT_HEALTH) < getStat(Stats.POWER)) r += 1; //i can kill you in one hit.
            if (t is Player) {
                Player p = t;
                if (p.aspect == Aspects.VOID) r += -1; //hard to see
                if (p.aspect == Aspects.LIGHT) r += 1; //easy to see
            }
            //////session.logger.info("Added rating of $r to $t");
            ratings.add(r);
        }
        GameEntity ret;
        num chosen_rating = 0;
        for (num i = 0; i < targets.length; i++) {
            GameEntity checked = targets[i];
            num checked_rating = ratings[i];
            if (checked_rating >= chosen_rating) {
                //////session.logger.info("found a better target");
                chosen_rating = checked_rating;
                ret = checked; //equal, because want LAST thing in list to be preffered if all things equal since slowest.
            }
        }
        return ret;
    }

    void changeGrimDark(num val) {
        //stubb
    }

    void increasePower() {
        //stub for sprites, and maybe later consorts or carapcians
    }

    String describeBuffs() {
        List<String> ret = <String>[];
        Iterable<Stat> allStats = Stats.all;
        //;
        for (Stat stat in allStats) {
            double withbuffs = this.stats.derive(stat); // functionally this.stats[stat]
            double withoutbuffs = this.stats.derive(stat, (Buff b) => !b.combat);
            double diff = withbuffs - withoutbuffs;
            //;
            //only say nothing if equal to zero
            if (diff > 0) ret.add("more ${stat.emphaticPositive}");
            if (diff < 0) ret.add("less ${stat.emphaticPositive}");
        }
        if (ret.isEmpty) return "";
        return "${this.htmlTitleHP()} is feeling ${turnArrayIntoHumanSentence(ret)} than normal. ";
    }

    void modifyAssociatedStat(num modValue, AssociatedStat stat) {
        //modValue * stat.multiplier.
        //////session.logger.info("Modify associated stat $stat on $this by $modValue");
        if (stat.stat == Stats.RELATIONSHIPS) {
            for (num i = 0; i < this.relationships.length; i++) {
                this.relationships[i].value += modValue * stat.multiplier;
            }
        } else {
            this.addStat(stat.stat, modValue * stat.multiplier); // I hope this isn't doing something totally wonky -PL
        }
    }

    //sets current hp to max hp. mostly called after strifes assuming you'll use healing items
    void heal() {
        this.setStat(Stats.CURRENT_HEALTH, this.getStat(Stats.HEALTH));
    }

    String htmlTitleWithTip() {
        String ret = "";
        if (this.crowned != null) ret = "${ret}Crowned ";
        String pname = this.name;
        if (pname == "Yaldabaoth") {
            List<String> misNames = <String>[ 'Yaldobob', 'Yolobroth', 'Yodelbooger', "Yaldabruh", 'Yogertboner', 'Yodelboth'];
            ////session.logger.info("Yaldobooger!!! ${this.session.session_id}");
            pname = this.session.rand.pickFrom(misNames);
        }
        if (this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
        return "${getToolTip()}$ret$pname</span>"; //TODO denizens are aspect colored.  also, that extra span there is to close out the tooltip
    }

    //will be diff for carapaces
    List<Fraymotif> get fraymotifsForDisplay {
        List<Fraymotif> ret = new List<Fraymotif>.from(fraymotifs);
        for(Item item in sylladex) {
            if(item is MagicalItem) {
                MagicalItem m = item as MagicalItem;
                if(!(m is Ring) && !(m is Scepter) ) ret.addAll(m.fraymotifs);
            }
        }
       // ;
        return ret;
    }

    String htmlTitle() {
        String ret = "";
        if (this.crowned != null) ret = "${ret}Crowned ";
        String pname = this.name;
        if (pname == "Yaldabaoth") {
            List<String> misNames = <String>[ 'Yaldobob', 'Yolobroth', 'Yodelbooger', "Yaldabruh", 'Yogertboner', 'Yodelboth'];
            ////session.logger.info("Yaldobooger!!! ${this.session.session_id}");
            pname = this.session.rand.pickFrom(misNames);
        }
        if (this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
        return "$ret$pname"; //TODO denizens are aspect colored.  also, that extra span there is to close out the tooltip
    }

    //what gets displayed when you hover over any htmlTitle (even HP)
    String getToolTip() {
        if (Drawing.checkSimMode() == true) {
            return "<span>";
        }
        String ret = "<span class = 'tooltip'><span class='tooltiptext'><table>";
        ret += "<tr><td class = 'toolTipSection'>$name<hr>";

        ret += "</td>";
        Iterable<Stat> as = Stats.summarise;
        ret += "<td class = 'toolTipSection'>Stats<hr>";
        for (Stat stat in as) {
            ret += "$stat: ${getStat(stat).round()}<br>";
        }

        ret += "</td>";


        ret += "</td><td class = 'toolTipSection' rowspan='2'>Sylladex<hr>";
        ret += "Specibus: ${specibus.fullNameWithUpgrade}, Rank: ${specibus.rank}<br><br>";

        for(Item item in sylladex) {
            ret += "${item.fullNameWithUpgrade}<br>";
        }


        ret += "</td></tr><tr><td class = 'toolTipSection'>Fraymotifs<hr>";
        List<Fraymotif> confusion = fraymotifsForDisplay;
        //;
        for(Fraymotif f in confusion) {
            ret += "${f.name}<br>";
        }

        ret += "</td><td class = 'toolTipSection'>Relationships<hr>";
        for(Relationship r in relationships) {
            ret += "$r<br>";
        }
        ret += "</td></tr></table></span>";
        return ret;
    }

    String htmlTitleHP() {
        String ret = "<font color ='$fontColor'>";
        if (this.crowned != null) ret = "${ret}Crowned ";
        String pname = this.name;
        if (this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
        return "${getToolTip()}$ret$pname (${(this.getStat(Stats.CURRENT_HEALTH)).round()} hp, ${(this.getStat(Stats.POWER)).round()} power)</font></span>"; //TODO denizens are aspect colored. also, that extra span there is to close out the tooltip
    }

    void flipOut(String reason) {}

    String htmlTitleBasic() {
        String ret = "";
        if (this.crowned != null) ret = "${ret}Crowned ";
        return "$ret $name";
    }

    String htmlTitleBasicNoTip() {
        String ret = "";
        if (this.crowned != null) ret = "${ret}Crowned ";
        return "$ret $name";
    }

    void makeAlive() {
        this.dead = false;
        this.heal();
    }


    Relationship getRelationshipWith(GameEntity target) {
        //stub for boss fights where an asshole absconds.
        for (Relationship r in relationships) {
            if (r.target.id == target.id) {
                return r;
            }
        }
        return null;
    }

    //a standard RPG trope, even if they are your friend
    void lootCorpse(GameEntity corpse) {
        if(corpse == null) return;
        //so no concurrent mods (wouldu try to loop on items even as it removes items)
        List<Item> tmp = new List<Item>.from(corpse.sylladex.inventory);
       // ;
        if(corpse != this) sylladex.addAll(tmp);
        //;

    }

    void makeDead(String causeOfDeath, GameEntity killer, [bool allowLooting = true]) {
        if(session.mutator.lifeField) return; //does fucking nothing.
        this.dead = true;
        this.causeOfDeath = causeOfDeath;
        if(killer != null) {
            if(this is Player) {
                killer.playerKillCount ++;
            }else {
                killer.npcKillCount ++;
            }
            if(killer != null && allowLooting)  killer.lootCorpse(this);
        }
    }

    void interactionEffect(GameEntity ge) {
        //none
    }

    //takes in a stat name we want to use. for example, use only min luck to avoid bad events.
    double rollForLuck([Stat stat]) {
        if (stat == null) {
            return this.session.rand.nextDoubleRange(this.getStat(Stats.MIN_LUCK), this.getStat(Stats.MAX_LUCK));
        } else {
            //don't care if it's min or max, just compare it to zero.
            return this.session.rand.nextDouble(this.getStat(stat));
        }
    }

    void boostAllRelationshipsWithMeBy(num amount) {}
    void boostAllRelationshipsBy(num amount) {}
    List<GameEntity> getFriendsFromList(List<GameEntity> list) {
        return <GameEntity>[];
    }

    List<Relationship> getHearts() {
        return <Relationship>[];
    }

    List<Relationship> getDiamonds() {
        return <Relationship>[];
    }

    void processCardFor() {
        //does nothing, offspring will override if they need to
    }


    static String getEntitiesNames(List<GameEntity> ges) {
        return ges.map((i) => i.title()).join(','); //TODO put an and at the end.
    }

    static int generateID() {
        GameEntity._nextID += 1;
        return GameEntity._nextID;
    }

    static int getIDCopy() {
        return GameEntity._nextID;
    }

    Random get rand => this.session.rand;

  String title() {
      return name; //players will override this
  }

  void setImportantShit(Session newSession, List<AssociatedStat> newAssociatedStats, String newName, double strength, List<Fraymotif> newFraymotifs, bool denizenBeat, bool god) {
      ;
      //based off existing denizen code.  care about which aspect i am.
      //also make minion here.
      this.name = newName;
      this.session = newSession;
      if(denizenBeat) this.addBuff(new BuffDenizenBeaten());
      if(god) this.addBuff(new BuffGodTier());
      this.setStat(Stats.EXPERIENCE, strength);
      Map<Stat, num> tmpStatHolder = <Stat, num>{};
      tmpStatHolder[Stats.MIN_LUCK] = -10;
      tmpStatHolder[Stats.MAX_LUCK] = 10;
      tmpStatHolder[Stats.HEALTH] = 10;
      tmpStatHolder[Stats.CURRENT_HEALTH] = 10;
      tmpStatHolder[Stats.MOBILITY] = 10;
      tmpStatHolder[Stats.SANITY] = 10;
      tmpStatHolder[Stats.ALCHEMY] = 10;
      tmpStatHolder[Stats.FREE_WILL] = 10;
      tmpStatHolder[Stats.POWER] =10;
      tmpStatHolder[Stats.GRIST] = 100;
      tmpStatHolder[Stats.RELATIONSHIPS] = 10; //not REAL relationships, but real enough for our purposes.
      tmpStatHolder[Stats.SBURB_LORE] = 0;
      this.associatedStats = newAssociatedStats;
      for (num i = 0; i < associatedStats.length; i++) {
          //alert("I have associated stats: " + i);
          AssociatedStat stat = associatedStats[i];
          if(tmpStatHolder[stat.stat] != null) tmpStatHolder[stat.stat] += tmpStatHolder[stat.stat] * stat.multiplier * strength;
      }
      //denizen.setStats(tmpStatHolder.minLuck,tmpStatHolder.maxLuck,tmpStatHolder.hp,tmpStatHolder.mobility,tmpStatHolde.getStat(Stats.SANITY),tmpStatHolder.freeWill,tmpStatHolder.getStat(Stats.POWER),true, false, [],1000000);
      this.stats.setMap(tmpStatHolder);
      this.grist = strength * 100;
      this.setStat(Stats.CURRENT_HEALTH, this.getStat(Stats.HEALTH));
      this.fraymotifs = newFraymotifs;
  }
}


//need to know if you're from aspect, 'cause only aspect associatedStats will be used for fraymotifs.
//except for heart, which can use ALL associated stats. (cause none will be from aspect.)
class AssociatedStat {
    Stat stat;
    double multiplier;
    bool isFromAspect;

    AssociatedStat(Stat this.stat, this.multiplier, bool this.isFromAspect) {}

    void applyToPlayer(Player player) {
        player.associatedStats.add(new AssociatedStat(this.stat, this.multiplier, this.isFromAspect));
    }

    @override
    String toString() => "[$stat x $multiplier${this.isFromAspect ? " (from Aspect)" : ""}]";
}

/// AssociatedStat variant for use as a reference for "this will be random when given to a player" like in Void
class AssociatedStatRandom extends AssociatedStat {
    Iterable<Stat> stats;

    AssociatedStatRandom(Iterable<Stat> this.stats, num multiplier, bool isFromAspect):super(null, multiplier, isFromAspect);

    @override
    void applyToPlayer(Player player) {
        player.associatedStats.add(new AssociatedStat(player.rand.pickFrom(this.stats), this.multiplier, this.isFromAspect));
    }

    @override
    String toString() => "[(Random from $stats) x $multiplier${this.isFromAspect ? " (from Aspect)" : ""}]";
}

/// AssociatedStat variant for use as a reference for "will apply the player's interest stats when given" like in Heart
class AssociatedStatInterests extends AssociatedStat {

    AssociatedStatInterests(bool isFromAspect, [num multiplier = 1.0]):super(null, multiplier, isFromAspect);

    @override
    void applyToPlayer(Player player) {
        player.associatedStats.addAll(player.interest1.category.stats.map((AssociatedStat s) => new AssociatedStat(s.stat, s.multiplier * this.multiplier, this.isFromAspect)));
        player.associatedStats.addAll(player.interest2.category.stats.map((AssociatedStat s) => new AssociatedStat(s.stat, s.multiplier * this.multiplier, this.isFromAspect)));
    }

    @override
    String toString() => "[Stats assigned from player Interests x$multiplier]";
}

//can eventually have a duration, but for now, assumed to be the whole fight. i don't want fights to last long.
class BuffOld {
    BuffOld(Stat this.name, num this.value) {}

    Stat name;
    num value;
}

