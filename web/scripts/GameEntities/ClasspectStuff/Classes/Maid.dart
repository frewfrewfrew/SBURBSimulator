import "../../GameEntity.dart";
import "SBURBClass.dart";
import "../../../SBURBSim.dart";

import "../../../Lands/FeatureTypes/QuestChainFeature.dart";
import "../../../Lands/Reward.dart";
import "../../../Lands/Quest.dart";

class Maid extends SBURBClass {

    //what sort of quests rewards do I get?
    @override
    double itemWeight = 0.51;
    @override
    double fraymotifWeight = 0.01;
    @override
    double companionWeight = 0.51;

    @override
    List<String> levels = ["SCURRYWART SERVANT", "SAUCY PILGRIM", "MADE OF SUCCESS"];
    @override
    List<String> quests = ["doing the consorts' menial errands, like delivering an item to a dude standing RIGHT FUCKING THERE", "repairing various ways the session has been broken", "protecting various consorts with game powers"];
    @override
    List<String> postDenizenQuests = ["using their powers to help clean up the debris left from their Denizen actions. Who knew the term maid would be so literal", "watching over the consorts as they begin to rebuild", "following their consorts to ever larger pieces of debris", "empowering an army of consorts to clean out the last of the debris from their Denizen"];
    @override
    List<String> handles = ["meandering", "motley", "musing", "mischievous", "macabre", "maiden", "morose"];

    @override
    bool isProtective = false;
    @override
    bool isSmart = false;
    @override
    bool isSneaky = false;
    @override
    bool isMagical = false;
    @override
    bool isDestructive = false;
    @override
    bool isHelpful = true;

    Maid() : super("Maid", 0, true);

    @override
    bool highHinit() {
        return true;
    }

    @override
    bool isActive([double multiplier = 0.0]) {
        return false;
    }

    @override
    void initializeItems() {
        items = new WeightedList<Item>()
        //disney princess, house maid, shield maid.
        ..add(new Item("Maiden's Breath",<ItemTrait>[ItemTraitFactory.PLANT, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.PRETTY]))
        ..add(new Item("Feather Duster",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.STICK, ItemTraitFactory.FEATHER],shogunDesc: "Maids Weapon of Choice",abDesc:"Housemaid shit."))
        ..add(new Item("Valkyrie Shield",<ItemTrait>[ItemTraitFactory.PRETTY,ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.LEGENDARY, ItemTraitFactory.SHIELD,ItemTraitFactory.ADAMANTIUM],shogunDesc: "Another Weakling Piece of Metal But For Some Kind of Angel Woman I Guess?",abDesc:"Shieldmaid shit"))
        ..add(new Item("Maiden's Songbook",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.MUSICAL,ItemTraitFactory.BOOK],shogunDesc: "Smash Mouth Lyrics",abDesc:"Longing maiden shit."));

    }


    @override
    num modPowerBoostByClass(num powerBoost, AssociatedStat stat) {
        return powerBoost * 1.5;
    }

    @override
    void processCard() {
        storeCard("N4Igzg9grgTgxgUxALhAMQJYDsAmACAQzwFkCMcQAaELAgWyVQBEI8BhACwhgTCpAAuCAB4CUIACocEeOARgAHBALwYweADYQIAa2wBzPADMoWHQE9C+slgB0eCRgbHueCAHcsCHrQYw8AqwAbgRwUFB0ANx4eACC1tj2eACSRm6e3gi+3ngcBPgC0nh0EF6WRe7QGvg8ChqhMgQaGgFFRlrcBnjuGIV4QdjmGvZSWelePvQ5lVDVWADkKnlBMoH9oeF0hFjmJTxJyVhgQvnjmdn+M9W5BCsBrGDuCAgK2-glCkkA6h6UrWrGAhYAQEMCWIwYABekI0CHw0BUPCagOOtn4ACNQjp9DBoLgAHJTcQ-LD6WE-GA6WwKUn8AQwDD6fTeThAxDiAAMtgArPwwIgvGAJBAAKpYLRwHTiADaAF1+DwwLMBGAAMoglUy4AAHRoU11yF1quIAFEADJmvBfWIANRNqt1lF1IQ0UAQBt1AFoAEy6gC+8uo9MZzJg6oIKrNvDA3hlgcEDKZ3nDKoA4kihDA43TE6GU2ATQBHKBNbN+oA");
    }

    @override
    double getAttackerModifier() {
        return 0.33;
    }

    @override
    double getDefenderModifier() {
        return 3.0;
    }

    @override
    double getMurderousModifier() {
        return 1.5;
    }

    @override
    void initializeThemes() {
        /*
        new Quest(" "),
        new Quest(""),
        new Quest(" ")

        */
        addTheme(new Theme(<String>["Suburbs","Parks", "Playgrounds", "Swingsets","Tire Swings","Neighborhoods","Traffic"])
            ..addFeature(FeatureFactory.NATURESOUND, Feature.HIGH)
            ..addFeature(FeatureFactory.NATURESMELL, Feature.HIGH)
            ..addFeature(FeatureFactory.CALMFEELING, Feature.MEDIUM)
            ..addFeature(FeatureFactory.RUSTLINGSOUND, Feature.MEDIUM)
            ..addFeature(FeatureFactory.HAPPYFEELING, Feature.MEDIUM)
            ..addFeature(FeatureFactory.LAUGHINGSOUND, Feature.MEDIUM)

            ..addFeature(new PostDenizenFrogChain("Serve the  Frogs", [
                new Quest("The ${Quest.DENIZEN} has instructed the Home Owners Association to lift the ban on frogs. The ${Quest.PLAYER1} asks local  ${Quest.CONSORT} kids to help them collect frogs. The ${Quest.CONSORT}s agree with enthusiastic ${Quest.CONSORTSOUND}s.  It's a lively neighborhood event."),
                new Quest("The ${Quest.CONSORT} kids hit buttons on the ectobiology machine at random. The ${Quest.PLAYER1} shows them how to do it right, and soon everybody is helping out. A neighboring ${Quest.CONSORT} starts grilling some burgers and dogs so nobody goes hungry."),
                new Quest("A ${Quest.CONSORT} child has tripped over the final frog. They cry and ${Quest.CONSORTSOUND} at their skinned knee, but their pain is quickly forgotten when the ${Quest.PLAYER1} praises them for finding the frog.  Together,     "),
            ], new FrogReward(), QuestChainFeature.spacePlayer), Feature.WAY_HIGH)


            ..addFeature(new PostDenizenQuestChain("Serve the PTA", [
                new Quest("The ${Quest.PLAYER1} has adopted a local ${Quest.CONSORT} child to be their dear, sweet, precious daughter. It is time for them to go off to school.  Other ${Quest.CONSORT} parents ask the ${Quest.PLAYER1} to join the PTA."),
                new Quest("The PTA has the ${Quest.PLAYER1} running ragged. It seems like every time they turn around it's another thing they are ${Quest.CONSORTSOUND}ing about. "),
                new Quest("All this time catering to the PTA has paid off. Not only is the ${Quest.PLAYER1}'s dear sweet precious ${Quest.CONSORT} daughter doing well in school, but the ${Quest.PLAYER1} has been elected president of the PTA! They now have the ability to make real changes.  Somehow this feels even more satisfying than defeating the ${Quest.DENIZEN}. ")
            ], new RandomReward(), QuestChainFeature.defaultOption), Feature.WAY_LOW)
            ,  Theme.MEDIUM);
    }

}