import '../../../SBURBSim.dart';
import 'Aspect.dart';
import "../../../Lands/FeatureTypes/QuestChainFeature.dart";
import "../../../Lands/Reward.dart";
import "../../../Lands/Quest.dart";

class Void extends Aspect {

    //what sort of quests rewards do I get?
    @override
    double itemWeight = 1.0;
    @override
    double fraymotifWeight = 1.0;
    @override
    double companionWeight = 1.00;

    @override
    AspectPalette palette = new AspectPalette()
        ..accent = "#000066"
        ..aspect_light = '#0B1030'
        ..aspect_dark = '#04091A'
        ..shoe_light = '#CCC4B5'
        ..shoe_dark = '#A89F8D'
        ..cloak_light = '#00164F'
        ..cloak_mid = '#00103C'
        ..cloak_dark = '#00071A'
        ..shirt_light = '#033476'
        ..shirt_dark = '#02285B'
        ..pants_light = '#004CB2'
        ..pants_dark = '#003E91';

    @override
    List<String> landNames = new List<String>.unmodifiable(<String>["Silence", "Nothing", "Void", "Emptiness", "Tears", "Dust", "Night", "[REDACTED]", "???", "Blindness"]);

    @override
    List<String> levels = new List<String>.unmodifiable(<String>["KNOW-NOTHING ANKLEBITER", "INKY BLACK SORROWMASTER", "FISTICUFFSAFICTIONADO"]);

    @override
    List<String> handles = new List<String>.unmodifiable(<String>["Vagrant", "Vegetarian", "Veterinarian", "Vigilante", "Virtuoso"]);

    @override
    List<String> fraymotifNames = new List<String>.unmodifiable(<String>["Undefined", "untitled.mp4", "Void", "Disappearification", "Pumpkin", "Nothing", "Emptiness", "Invisible", "Dark", "Hole", "Solo", "Silent", "Alone", "Night", "Null", "[Censored]", "[???]", "Vacuous", "Abyss", "Noir", "Blank", "Tenebrous", "Antithesis", "404"]);


    @override
    String denizenSongTitle = "Silence";

    @override
    String denizenSongDesc = " A yawning silence rings out. It is the NULL Reality sings to keep the worlds on their dance. The OWNER is strengthened and healed. The ENEMY is weakened and hurt. And that is all there is to say on the matter. ";


    @override
    List<String> denizenNames = new List<String>.unmodifiable(<String>['Void', 'Selene', 'Erebus', 'Nix', 'Artemis', 'Kuk', 'Kaos', 'Hypnos', 'Tartarus', 'Hnir', 'Skoll', "Czernobog", 'Vermina', 'Vidar', 'Asteria', 'Nocturne', 'Tsukuyomi', 'Leviathan', 'Hecate', 'Harpocrates', 'Diova']);


    @override
    List<String> symbolicMcguffins = ["void","obscurity", "irrelevance", "stealth", "null", "silence", "ignorance", "vacuum", "static"];
    @override
    List<String> physicalMcguffins = ["void","cloak", "disguise", "shadow", "cardboard box", "secret plan"];

    @override
    void initializeItems() {
        items = new WeightedList<Item>()
            ..add(new Item("Cardboard Box",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING],shogunDesc: "Shoguns Old Home",abDesc:"It's the highest level void item. Except not. It's a box. Asshole."))
            ..add(new Item("Hole Punch",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING],shogunDesc: "Paper Impaler"))
            ..add(new Item("Smoke Bombs",<ItemTrait>[ItemTraitFactory.EXPLODEY, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING,ItemTraitFactory.GRENADE],shogunDesc: "Vape Grenades"))
            ..add(new Item("Tribal Mask",<ItemTrait>[ItemTraitFactory.BONE, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING, ItemTraitFactory.SCARY, ItemTraitFactory.UGLY],shogunDesc: "Ancient Face"))
            ..add(new Item("Opera Mask",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING, ItemTraitFactory.CLASSY],shogunDesc: "Phantom of the Opera Mask"))
            ..add(new Item("Black Hole in a Bottle.",<ItemTrait>[ItemTraitFactory.ASPECTAL,ItemTraitFactory.LEGENDARY, ItemTraitFactory.GREENSUN,ItemTraitFactory.OBSCURING, ItemTraitFactory.GLASS],shogunDesc: "Eternal Suffering in a Jar",abDesc:"Jegus fuck, don't break this."));
    }

    @override
    List<AssociatedStat> stats = new List<AssociatedStat>.unmodifiable(<AssociatedStat>[
        new AssociatedStatRandom(Stats.pickable, 3.0, true), //really good at one thing
        new AssociatedStatRandom(Stats.pickable, -1.0, true), //hit to another thing.
        new AssociatedStat(Stats.MIN_LUCK, -1.0, true), //hit to another thing.
        new AssociatedStat(Stats.SBURB_LORE, 0.2, false) //yes, technically it's from an aspect, but it's not NORMAL.
    ]);

    Void(int id) :super(id, "Void", isCanon: true);

    @override
    String activateCataclysm(Session s, Player p) {
        return s.mutator.voidStuff(s, p);
    }



    @override
    void initializeThemes() {

        /*
        new Quest(""),
                new Quest(""),
                new Quest(""),
                new DenizenFightQuest("","","")
         */
        addTheme(new Theme(<String>["Nothing","Void","Emptiness","Dust", "Shadows", "Nowhere", "Absence"])
            ..addFeature(FeatureFactory.SILENCE, Feature.HIGH)
            ..addFeature(FeatureFactory.NOTHINGFEELING, Feature.HIGH)
            ..addFeature(FeatureFactory.NOTHINGSMELL, Feature.HIGH)
            ..addFeature(FeatureFactory.ECHOSOUND, Feature.HIGH)

            ..addFeature(new PostDenizenQuestChain("Be Forgettable", [
                new Quest("A big party is being held to celebrate the defeat of ${Quest.DENIZEN} and the ${Quest.PLAYER1} is invited as the guest of honor. There are promises of god food, including a gigantic cake. At the door a burly ${Quest.CONSORT} stands with a clipboard. He eyes the ${Quest.PLAYER1} approaching and shakes his head. ‘You’re not on the list, so beat it.’ The ${Quest.PLAYER1} tries to explain that they’re the planet’s hero and the one who beat ${Quest.DENIZEN}, making them the guest of honor, but the bouncer just laughs. ‘If you’re supposed to be the hero, why haven’t I heard of you already?’"),
                new Quest("The ${Quest.PLAYER1} asks other guests to vouch for them, but all of them are having trouble recognizing the ${Quest.PLAYER1}. There’s just something about the ${Quest.PLAYER1} that makes them so forgettable. They go home and bring back photos of themself with other ${Quest.PLAYER1}s as proof that they’re also a hero, but the bouncer dismisses the photos as very realistic but clearly edited. What a pain."),
                new Quest("The ${Quest.PLAYER1} gives up trying to convince the ${Quest.CONSORT} bouncer of their existence. If they’re not going to be recognized, they might as well take it all the way. They use their void powers to become completely unnoticeable and walk past the bouncer while making a number of obscene gestures. The ${Quest.CONSORT} hosting the party approaches the ${Quest.PLAYER1} as soon they turn off their powers to join the party. ‘There you are! You know it’s very rude for the guest of honor to be so late. I’m really disappointed in you.’ Bluh.")
            ], new ItemReward(items), QuestChainFeature.defaultOption), Feature.WAY_LOW)

            ..addFeature(new DenizenQuestChain("Go to Nowhere", [
                new Quest("The ${Quest.PLAYER1} has wandered around for hours and has found nothing new to do. There is NO way this is the end of the land. What is going on?"),
                new Quest("Huh....what....what is this area of a wall that looks....a little different? Like the shadows aren't falling right on it? The ${Quest.PLAYER1} leans against it and stumbles into a ...weirdly hard to see area. Huh. The ${Quest.PLAYER1} wonders if maybe the rest of their quests are in places like this?"),
                new Quest("Holy FUCK that was the BEST dungeon of ALL TIME!!!  The ${Quest.PLAYER1} sure feels bad for anybody who missed it.  Just, that TWIST at the end, man. So great."),
                new DenizenFightQuest("You're....really having trouble following what's going on. The ${Quest.PLAYER1} emerges from one of those glitchy areas you can't see into, obviously fighting the ${Quest.DENIZEN}. What the fuck is even happening!? ","The ${Quest.PLAYER1} won!  That's....GOOD, you think. The ${Quest.DENIZEN} was probably an asshole.","The ${Quest.PLAYER1} lost.  That's....BAD, you think. The ${Quest.DENIZEN} is probably an asshole.")
            ], new DenizenReward(), QuestChainFeature.defaultOption), Feature.WAY_LOW)
            ,  Theme.HIGH);

        addTheme(new Theme(<String>["???", "[REDACTED]","[CENSORED]", "Censorship", "Conspiracies"])
            ..addFeature(FeatureFactory.SILENCE, Feature.MEDIUM)
            ..addFeature(FeatureFactory.NOTHINGFEELING, Feature.MEDIUM)
            ..addFeature(FeatureFactory.NOTHINGSMELL, Feature.MEDIUM)
            ..addFeature(FeatureFactory.DECEITSMELL, Feature.HIGH)

            ..addFeature(new PostDenizenQuestChain("Reveal the Tomes", [
                new Quest("Even with the victory of the ${Quest.PLAYER1} over the villainous ${Quest.DENIZEN}, there are still problems. Ancient libraries lie crumbling in the denizen's lair, secrets hidden in languages long forgotten by ${Quest.CONSORT} and carapace alike. Even the libraries on Prospit contain scant knowledge of this cryptic tongue, but the covers promise great power and mastery over the aspect of Void. Perhaps study of the ${Quest.PHYSICALMCGUFFIN} will provide insight."),
                new Quest("Hours of study yield little progress until the ${Quest.PLAYER1} has a breakthrough regarding symbols on the ${Quest.PHYSICALMCGUFFIN}. It seems that through analysis of the symbols on the ${Quest.PHYSICALMCGUFFIN} using Zipf's Law, you can piece together which common words in normal language match up with common words in this strange script!"),
                new Quest("The ${Quest.PLAYER1} plunders ancient tombs, searching for a rumored Rosetta Stone of sorts, one that promises to provide more insight on rather uncommon words in the books of ${Quest.DENIZEN}'s library. After countless false starts and empty tombs, not only does the ${Quest.PLAYER1}find it, a nearly complete record of the history of the land is found, and by comparing it to known records, they can translate even MORE words, not to mention new parts of history they'll uncover once they translate it all."),
                new Quest("The ${Quest.PLAYER1}, after hours of striving and looking into dark and forgotten places, poring over secret tomes, and studious work in the field of ${Quest.PHYSICALMCGUFFIN}ology, has finally translated most of the books in the library. The mystical techniques of the ancients (who probably never existed, but hey) are now open to them.")
            ], new FraymotifReward("Ancient Knowledge"), QuestChainFeature.playerIsSmartClass), Feature.HIGH)

            ..addFeature(new DenizenQuestChain("[REDACTED]", [
                new Quest("Apparently the denizen [REDACTED] has been [REDACTED]ing all the [REDACTED] and everyone is starting to get a little pissed at them. Can the ${Quest.PLAYER1} help? "),
                new Quest("The ${Quest.PLAYER1} [REDACTED]s and it actually works! Everyone ${Quest.CONSORTSOUND} in surprise. This might just be crazy enough to work."),
                new Quest("Wait, who would have thought that the [REDACTED] would be weak to [REDACTED]??? This is officially the dumbest fight in all of Paradox Space."),
                new DenizenFightQuest("It's time to fight the [REDACTED] for real this time. Their reign of [REDACTED] will finally be at an end.","The ${Quest.DENIZEN} is defeated. FINALLY they can stop censoring everything on this stupid planet, especially ${Quest.CONSORT}s.","[REDACTED]")
            ], new DenizenReward(), QuestChainFeature.defaultOption), Feature.WAY_LOW)

            , Theme.HIGH);


        addTheme(new Theme(<String>["Silence","Blindness","Deafness","Blindfolds","Earplugs","Sensory Deprivation"])
            ..addFeature(FeatureFactory.SILENCE, Feature.HIGH)
            ..addFeature(FeatureFactory.NOTHINGFEELING, Feature.HIGH)
            ..addFeature(FeatureFactory.NOTHINGSMELL, Feature.HIGH)
            //could make the default quest a knight/page quest in second pass. fighting with nothingness as an enemy and fighting with nothingness as a weapon and all
            ..addFeature(new DenizenQuestChain("Walk of Faith", [
                new Quest("Suddenly the ${Quest.PLAYER1} can't see or hear. Oh god, what is going on?  They feel around in close to a panic, until they find a button. After a moments deliberation, they press it. Suddenly they can see and hear again. Huh."),
                new Quest("The ${Quest.PLAYER1} sees a red button at the other end of a cluttered hallway, inside a dungeon. Their bad feeling is confirmed when they suddenly can't see or hear again. After many stubbed toes and bruised shins, they finally make it to the button and press it to regain their senses."),
                new Quest("The newest button is in the middle of a single large room with pitfall traps scattered throughout and underlings to boot. Are you fucking kidding me!? When the ${Quest.PLAYER1} loses their senses, they seriously consider just sitting down and seeing if it wears off, but those underlings would probably attack in the mean time. The ${Quest.PLAYER1} begins slowly making their way towards the button. Half way through, they realize with a start that the Underlings haven't tried to attack them. Huh.   When they finally press the button, the Underlings suddenly whirl to face them. Were they...INVISIBLE while they were blind? It's short work to defeat the underlings."),
                new Quest("Faced with a huge underling that is probably too high a level to fight, the ${Quest.PLAYER1} is struck with sudden inspiration. They blindfold themselves and do their best to block out their ability to hear, as well. They make their way to where the giant Underling was and begin to strife them. When they stop being aware of flailing, they remove their blindfold and find the giant Underling has become a giant pile of grist. HELL YES, VOID POWERS RULE!!!  "),
                new DenizenFightQuest("The ${Quest.PLAYER1} attempts to sneak up on the ${Quest.DENIZEN} while blindfolded. It dodges. Oh well, guess you can't out-void a Void boss.  Time for a regular strife!","The ${Quest.PLAYER1} has defeated the major challenge of their land.","The ${Quest.PLAYER1} is going to have to try again.")
            ], new DenizenReward(), QuestChainFeature.defaultOption), Feature.WAY_LOW)
            , Theme.HIGH); // end theme
    }
}