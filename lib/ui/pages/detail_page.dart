import 'package:event_app/app/configs/colors.dart';
import 'package:event_app/app/resources/constant/named_routes.dart';
import 'package:event_app/data/category_enum.dart';
import 'package:event_app/data/event_model.dart';
import 'package:event_app/data/ticket_model.dart';
import 'package:event_app/ui/widgets/circle_button.dart';
import 'package:event_app/ui/widgets/custom_app_bar.dart';
import 'package:event_app/ui/widgets/stack_participant.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> eventData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final EventModel eventModel = EventModel.fromJson(eventData);
    return Scaffold(
      appBar:
          const PreferredSize(preferredSize: Size(0, 0), child: CustomAppBar()),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Column(
                  children: [
                    _buildAppBar(context),
                    const SizedBox(height: 24),
                    _buildCardImage(eventModel),
                    const SizedBox(height: 16),
                    _buildDescription(eventModel),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomBar(context, eventModel),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, EventModel eventModel) =>
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
          decoration: const BoxDecoration(color: AppColors.whiteColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price",
                    style:
                        TextStyle(fontSize: 12, color: AppColors.greyTextColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        eventModel.isFree
                            ? "Free"
                            : eventModel.minPrice == eventModel.maxPrice
                                ? "\$${eventModel.minPrice.toStringAsFixed(0)}"
                                : "\$${eventModel.minPrice.toStringAsFixed(0)} - \$${eventModel.maxPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!eventModel.isFree)
                        const Text(
                          " /Person",
                          style: TextStyle(
                              fontSize: 12, color: AppColors.greyTextColor),
                        )
                    ],
                  )
                ],
              ),
              ElevatedButton(
                onPressed: eventModel.hasAvailableTickets
                    ? () => Navigator.pushNamed(
                          context,
                          NamedRoutes.ticketScreen,
                          arguments: eventModel.toJson(),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    maximumSize: const Size(200, 150)),
                child: Text(
                  eventModel.hasAvailableTickets
                      ? "Get Tickets"
                      : "Sold Out",
                  style:
                      const TextStyle(color: AppColors.whiteColor, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildCardImage(EventModel eventModel) => Stack(
        children: [
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16)),
          ),
          Container(
            width: double.infinity,
            height: 310,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  eventModel.image,
                ),
              ),
            ),
          ),
          Positioned(
            right: 22,
            top: 22,
            child: Container(
              height: 65,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eventModel.date.split(" ")[0],
                  ),
                  Text(
                    eventModel.date.split(" ")[1],
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );

  Widget _buildAppBar(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleButton(
            icon: 'assets/images/ic_arrow_left.png',
            onTap: () => Navigator.pop(context),
          ),
          const Text(
            "Detail",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CircleButton(
            icon: 'assets/images/ic_dots.png',
            onTap: () {},
          )
        ],
      );

  _buildDescription(EventModel eventModel) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventModel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.greyTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              eventModel.isOnline ? "Online Event" : eventModel.location,
                              style:
                                  const TextStyle(color: AppColors.greyTextColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    eventModel.category.displayName,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            // Event Details Row
            Row(
              children: [
                if (eventModel.startTime != null) ...[
                  const Icon(Icons.access_time, size: 16, color: AppColors.greyTextColor),
                  const SizedBox(width: 4),
                  Text(
                    eventModel.startTime!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                const Icon(Icons.people, size: 16, color: AppColors.greyTextColor),
                const SizedBox(width: 4),
                Text(
                  "${eventModel.attendees} attending",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const StackParticipant(
              fontSize: 14,
              width: 30,
              height: 30,
              positionText: 100,
            ),
            const SizedBox(height: 20),
            // Organizer Section
            const Text(
              "Organizer",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: eventModel.organizer.profileImage != null
                                ? NetworkImage(eventModel.organizer.profileImage!)
                                : null,
                            child: eventModel.organizer.profileImage == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  eventModel.organizer.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${eventModel.organizer.rating.toStringAsFixed(1)} • ${eventModel.organizer.eventsHosted} events",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.greyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.greyTextColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Ticket Types Section
            const Text(
              "Ticket Options",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...eventModel.tickets.map((ticket) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ticket.isSoldOut
                          ? AppColors.greyColor.withOpacity(0.3)
                          : AppColors.primaryLightColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.type.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ticket.isSoldOut
                                    ? AppColors.greyTextColor
                                    : AppColors.blackTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.isSoldOut
                                  ? "Sold Out"
                                  : "${ticket.available} available",
                              style: TextStyle(
                                fontSize: 12,
                                color: ticket.isSoldOut
                                    ? AppColors.greyTextColor
                                    : AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        ticket.price == 0
                            ? "Free"
                            : "\$${ticket.price.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ticket.isSoldOut
                              ? AppColors.greyTextColor
                              : AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventModel.description,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: AppColors.greyTextColor,
                fontSize: 13,
                height: 1.75,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
}
