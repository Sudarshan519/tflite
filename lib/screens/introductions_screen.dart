import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';

AppBar appbar = AppBar(
  leading: SizedBox(),
);

class IntroScreen extends StatelessWidget {
  IntroScreen({Key? key}) : super(key: key);
  final MainController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Intro Screen",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum eum illum eos, dolores impedit, consectetur corporis molestias mollitia corrupti tempore veniam repudiandae expedita nesciunt distinctio! Commodi id illum, veritatis tempora laboriosam corrupti optio maxime doloribus soluta molestiae, tempore hic, deleniti dolorum voluptate! Adipisci tempora natus illo excepturi omnis dolorem aliquam dignissimos iure cumque nostrum quasi dolore voluptatum accusantium ipsa quis ea temporibus distinctio, consectetur accusamus doloremque. Tempora numquam velit libero voluptas beatae nobis commodi pariatur dolore reiciendis odio, suscipit natus id cupiditate placeat. Fugit reiciendis quasi praesentium quis omnis quas nam distinctio, est at vero similique itaque accusantium, numquam molestiae modi cupiditate adipisci excepturi vitae dolorem perferendis et ipsa necessitatibus? Hic, officiis. Laboriosam quidem ab animi. Possimus sit asperiores quam odit fugit suscipit saepe eos. Cumque aliquam dignissimos ab nemo beatae quod tenetur in quibusdam, aperiam iure quidem, quaerat omnis a. Ducimus ipsam quidem distinctio magni perferendis deserunt aliquam, commodi enim reiciendis officia autem possimus id suscipit veniam expedita, accusamus voluptatem repudiandae impedit quisquam aperiam! Earum quisquam ut, inventore recusandae dolorum iusto corporis soluta tempora, unde quae eum dicta magnam illum impedit perferendis dolores vel nemo iure iste accusamus! Sequi aperiam fugiat facilis at doloremque omnis accusamus, inventore similique, quasi, fuga velit possimus odit quam. Ducimus illo eaque possimus veniam voluptate expedita, rerum tempore velit laborum atque placeat corrupti nisi nostrum asperiores! Nulla illum neque autem harum vitae! Deserunt officia ab explicabo minus voluptates libero dolor beatae temporibus quaerat aspernatur, dolorem hic laudantium assumenda, consequuntur, quam odit. Suscipit eius nesciunt exercitationem neque aspernatur quia esse architecto tempora quaerat necessitatibus odio porro id, similique sapiente deleniti minima. Pariatur provident libero, eos ducimus ut ipsa cum officiis quia officia sequi repudiandae itaque expedita excepturi doloremque nesciunt aspernatur rerum! Dolore, fugit? Aut assumenda quibusdam laborum distinctio aspernatur odio cupiditate ab et iure eligendi eveniet exercitationem nobis, adipisci amet quasi? Illo dignissimos aliquam nulla veritatis non dolore voluptates beatae ea laudantium, unde autem consequuntur repudiandae quod, ipsam, voluptatum exercitationem a. Neque facere laudantium temporibus fugit laborum molestiae iure rem voluptates blanditiis commodi dolore quis nesciunt doloremque, consequatur omnis atque quos, deserunt totam, sunt reiciendis id aliquid voluptatem magnam. Nihil error consectetur ratione aliquam illum, vitae soluta illo quis eligendi sed facilis dolorum omnis! Qui, sed molestiae. Laudantium soluta quia aspernatur tempora cum necessitatibus minima doloribus, consectetur ipsam dolorem adipisci. Eveniet modi ex numquam pariatur sint assumenda dolor repellendus, praesentium unde dolorum accusantium delectus at possimus adipisci atque commodi. Adipisci, rem atque commodi dignissimos quam tenetur omnis eius nesciunt tempore doloribus sequi veritatis dolorem distinctio delectus assumenda voluptate deserunt aliquid similique magnam aperiam molestiae? Culpa officia quaerat ratione doloremque iure, nihil impedit ipsa quidem asperiores vel quas totam eum fugit explicabo possimus porro vero. Nulla aut eos quo pariatur unde voluptatibus inventore quis, fuga repudiandae velit nisi vitae esse temporibus alias delectus voluptates ut labore autem dicta ab iusto. Inventore, earum ex? Eos numquam dolor repellat nobis! Iusto ea temporibus eligendi aliquam, pariatur at eveniet nostrum placeat alias modi repudiandae qui iure. Doloremque mollitia pariatur neque. Molestias porro, sapiente dignissimos mollitia repellat est debitis voluptatum, ipsa consequatur perspiciatis incidunt culpa nesciunt fuga ullam. Libero, nostrum pariatur? Explicabo, debitis reprehenderit minima quis esse iure, eveniet repellat recusandae hic sint saepe repellendus vitae nihil veniam cupiditate mollitia nam. Aut repudiandae a, qui possimus, quaerat eveniet iste sunt aspernatur tempora quam facilis sint facere. Doloribus animi at, beatae minima autem sit voluptate laudantium deleniti suscipit est, doloremque quis nemo blanditiis sint. Aliquid voluptate ea maiores consequatur magni expedita, aperiam vitae dicta aliquam quibusdam numquam. Sunt cum provident ab, nostrum accusantium autem maxime aut neque magnam eum atque officia?"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: Get.width,
                child: ElevatedButton(
                    onPressed: () {
                      controller.pageController.nextPage(
                          duration: 300.milliseconds, curve: Curves.ease);
                    },
                    child: Text("Start Tutorial")),
              ),
            )
          ],
        ),
      ),
    );
  }
}
