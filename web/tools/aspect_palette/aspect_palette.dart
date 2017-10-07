
import 'dart:async';
import "dart:html";
import "dart:math" as Math;

import "../../scripts/SBURBSim.dart";

import "../../scripts/includes/colour.dart";
import "../../scripts/includes/colour_picker.dart";

import "../../scripts/Rendering/3d/three.dart" as THREE;


void main() {
    Element stuff = querySelector("#stuff");

    /*new Timer(new Duration(seconds: 1),()
    {
        //print("event stuff:");
        //print(querySelector("#testpicker")); //.onChange);

        ColourPicker.create(querySelector("#testpicker"));//..onChange.listen((Event e) => //print((e.target as InputElement).value)));
    });*/

    //testDrawing();


}

Future<bool> testDrawing() async {
    Element stuff = querySelector("#stuff");

    // preload to be fair
    await Loader.getResource("images/guide_bot.png");
    await Renderer.loadThree();

    int dim = 5;
    int space = 10;

    {
        DateTime then = new DateTime.now();

        CanvasElement testcanvas = new CanvasElement(width: 640, height: 480);
        CanvasRenderingContext2D ctx = testcanvas.context2D;

        for (int x = 0; x < dim; x++) {
            for (int y = 0; y < dim; y++) {
                ctx.drawImage(await Loader.getResource("images/guide_bot.png"), space * x, space * y);
            }
        }

        stuff.append(testcanvas);

        DateTime now = new DateTime.now();
        int mis = now.microsecondsSinceEpoch - then.microsecondsSinceEpoch;

        print("2d: ${mis / 1000}ms");
    }

    {
        DateTime then = new DateTime.now();

        RenderJob job = await RenderJob.create(640, 480);

        ImageElement img = await Loader.getResource("images/guide_bot.png");
        THREE.Mesh image = new THREE.Mesh(new THREE.PlaneGeometry(img.width, img.height, 1, 1), new THREE.MeshBasicMaterial(new THREE.MeshBasicMaterialProperties(map: new THREE.Texture(img)
            ..magFilter = THREE.NearestFilter
            ..minFilter = THREE.NearestFilter
            ..needsUpdate = true))
            ..transparent = true);
        image.position
            ..x = img.width / 2
            ..y = img.height / 2;
        image.rotation.x = Math.PI;

        for (int x = 0; x < dim; x++) {
            for (int y = 0; y < dim; y++) {
                //await job.addImage("images/guide_bot.png", 50 * x, 50 * y);
                job.scene.add(image.clone(false)
                    ..position.x += space * x..position.y += space * y);
            }
        }

        stuff.append(job.dispatch());

        DateTime now = new DateTime.now();
        int mis = now.microsecondsSinceEpoch - then.microsecondsSinceEpoch;

        print("3d: ${mis / 1000}ms");
    }

    return true;
}

void checkLABRanges() {
    double min_l = double.INFINITY;
    double max_l = double.NEGATIVE_INFINITY;

    double min_a = double.INFINITY;
    double max_a = double.NEGATIVE_INFINITY;

    double min_b = double.INFINITY;
    double max_b = double.NEGATIVE_INFINITY;

    for (int r = 0; r<256; r++) {
        for (int g = 0; g<256; g++) {
            for (int b = 0; b<256; b++) {
                Colour col = new Colour(r,g,b);

                min_l = Math.min(min_l, col.lab_lightness_scaled);
                max_l = Math.max(max_l, col.lab_lightness_scaled);

                min_a = Math.min(min_a, col.lab_a_scaled);
                max_a = Math.max(max_a, col.lab_a_scaled);

                min_b = Math.min(min_b, col.lab_b_scaled);
                max_b = Math.max(max_b, col.lab_b_scaled);
            }
        }
    }

    //print("L: $min_l,$max_l, a: $min_a,$max_a, b: $min_b,$max_b");
}

CanvasElement makeGradientSwatch() {
    CanvasElement canvas = new CanvasElement(width: 200, height:200);
    CanvasRenderingContext2D ctx = canvas.context2D;

    Random rand = new Random();

    //double brightness = rand.nextDouble() * 0.4 + 0.5;
    //double sat = rand.nextDouble() * 0.2 + 0.5;

    //Colour col1 = new Colour.hsv(rand.nextDouble(), rand.nextDouble() * 0.1 + sat, rand.nextDouble() * 0.3 + brightness);
    //Colour col2 = new Colour.hsv(rand.nextDouble(), rand.nextDouble() * 0.1 + sat, rand.nextDouble() * 0.3 + brightness);

    //Colour col1 = new Colour.fromHex(0xFF0000);
    //Colour col2 = new Colour.fromHex(0x00FF00);

    double lightness = rand.nextDouble() * 0.4 + 0.3;
    double l1 = (rand.nextDouble() * 0.6 - 0.3 + lightness);
    l1 = 1-((1-l1)*(1-l1));
    double l2 = (rand.nextDouble() * 0.6 - 0.3 + lightness);
    l2 = 1-((1-l2)*(1-l2));

    Colour col1 = new Colour.labScaled(l1, rand.nextDouble(), rand.nextDouble());
    Colour col2 = new Colour.labScaled(l2, rand.nextDouble(), rand.nextDouble());

    int w = canvas.width;
    int h = canvas.height;

    ImageData data = ctx.getImageData(0,0,w,h);

    for (int x = 0; x<w; x++) {
        for (int y = 0; y<h; y++) {
            int index = ((w*y) +x) * 4;

            double frac = x / (w*2) + y / (h*2);

            Colour mix = col1.mix(col2, frac, true);

            data.data[index] = mix.red;
            data.data[index+1] = mix.green;
            data.data[index+2] = mix.blue;
            data.data[index+3] = 255;
        }
    }

    ctx.putImageData(data, 0, 0);

    return canvas;
}