import 'package:flutter/material.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';

AppBar appbar = AppBar(
  leading: const SizedBox(),
);

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final MainController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Intro Screen",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum eum illum eos, dolores impedit, consectetur corporis molestias mollitia corrupti tempore veniam repudiandae expedita nesciunt distinctio! Commodi id illum, veritatis tempora laboriosam corrupti optio maxime doloribus soluta molestiae, tempore hic, deleniti dolorum voluptate! Adipisci tempora natus illo excepturi omnis dolorem aliquam dignissimos iure cumque nostrum quasi dolore voluptatum accusantium ipsa quis ea temporibus distinctio, consectetur accusamus doloremque. Tempora numquam velit libero voluptas beatae nobis commodi pariatur dolore reiciendis odio, suscipit natus id cupiditate placeat. Fugit reiciendis quasi praesentium quis omnis quas nam distinctio, est at vero similique itaque accusantium, numquam molestiae modi cupiditate adipisci excepturi vitae dolorem perferendis et ipsa necessitatibus? Hic, officiis. Laboriosam quidem ab animi. Possimus sit asperiores quam odit fugit suscipit saepe eos. Cumque aliquam dignissimos ab nemo beatae quod tenetur in quibusdam, aperiam iure quidem, quaerat omnis a. Ducimus ipsam quidem distinctio magni perferendis deserunt aliquam, commodi enim reiciendis officia autem possimus id suscipit veniam expedita, accusamus voluptatem repudiandae impedit quisquam aperiam! Earum quisquam ut, inventore recusandae dolorum iusto corporis soluta tempora, unde quae eum dicta magnam illum impedit perferendis dolores vel nemo iure iste accusamus! Sequi aperiam fugiat facilis at doloremque omnis accusamus, inventore similique, quasi, fuga velit possimus odit quam. Ducimus illo eaque possimus veniam voluptate expedita, rerum tempore velit laborum atque placeat corrupti nisi nostrum asperiores! Nulla illum neque autem harum vitae! Deserunt officia ab explicabo minus voluptates libero dolor beatae temporibus quaerat aspernatur, dolorem hic laudantium assumenda, consequuntur, quam odit. Suscipit eius nesciunt exercitationem neque aspernatur quia esse architecto tempora quaerat necessitatibus odio porro id, similique sapiente deleniti minima. Pariatur provident libero, eos ducimus ut ipsa cum officiis quia officia sequi repudiandae itaque expedita excepturi doloremque nesciunt aspernatur rerum! Dolore, fugit? Aut assumenda quibusdam laborum distinctio aspernatur odio cupiditate ab et iure eligendi eveniet exercitationem nobis, adipisci amet quasi?",
                textAlign: TextAlign.justify,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                      onPressed: () {
                        controller.pageController.nextPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text("Start Tutorial")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
