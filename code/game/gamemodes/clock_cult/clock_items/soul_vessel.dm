//Soul vessel: An ancient positronic brain that serves only Ratvar.
/obj/item/device/mmi/posibrain/soul_vessel
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	var/clockwork_desc = "A soul vessel, an ancient relic that can attract the souls of the damned or simply rip a mind from an unconscious or dead human.\n\
	<span class='brass'>If active, can serve as a positronic brain, placable in cyborg shells or clockwork construct shells.</span>"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	req_access = list()
	braintype = "Servant"
	begin_activation_message = "<span class='brass'>You activate the cogwheel. It hitches and stalls as it begins spinning.</span>"
	success_message = "<span class='brass'>The cogwheel's rotation smooths out as the soul vessel activates.</span>"
	fail_message = "<span class='warning'>The cogwheel creaks and grinds to a halt. Maybe you could try again?</span>"
	new_role = "Soul Vessel"
	welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a soul vessel - a clockwork mind created by Ratvar, the Clockwork Justiciar.\n\
	You answer to Ratvar and his servants. It is your discretion as to whether or not to answer to anyone else.\n\
	The purpose of your existence is to further the goals of the servants and Ratvar himself. Above all else, serve Ratvar.</b>"
	new_mob_message = "<span class='brass'>The soul vessel emits a jet of steam before its cogwheel smooths out.</span>"
	dead_message = "<span class='deadsay'>Its cogwheel, scratched and dented, lies motionless.</span>"
	fluff_names = list("Servant")
	clockwork = TRUE
	autoping = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/device/mmi/posibrain/soul_vessel/New()
	..()
	all_clockwork_objects += src

/obj/item/device/mmi/posibrain/soul_vessel/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/device/mmi/posibrain/soul_vessel/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/item/device/mmi/posibrain/soul_vessel/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>You fiddle around with [src], to no avail.</span>"
		return 0
	..()

/obj/item/device/mmi/posibrain/soul_vessel/attack(mob/living/target, mob/living/carbon/human/user)
	if(!is_servant_of_ratvar(user) || !ishuman(target) || used || (brainmob && brainmob.key))
		..()
	if(is_servant_of_ratvar(target))
		user << "<span class='heavy_alloy'>\"It would be more wise to revive your allies, friend.\"</span>"
		return
	var/mob/living/carbon/human/H = target
	var/obj/item/bodypart/head/HE = H.get_bodypart("head")
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)
	if(!HE)
		user << "<span class='warning'>[H] has no head, and thus no mind!</span>"
		return
	if(H.stat == CONSCIOUS)
		user << "<span class='warning'>[H] must be dead or unconscious for you to claim [H.p_their()] mind!</span>"
		return
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEHAIR)
			user << "<span class='warning'>[H]'s head is covered, remove [H.head] first!</span>"
			return
	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(I.flags_inv & HIDEHAIR)
			user << "<span class='warning'>[H]'s head is covered, remove [H.wear_mask] first!</span>"
			return
	if(!B)
		user << "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>"
		return
	if(!H.key)
		user << "<span class='warning'>[H] has no mind to claim!</span>"
		return
	playsound(H, 'sound/misc/splort.ogg', 60, 1, -1)
	playsound(H, 'sound/magic/clockwork/anima_fragment_attack.ogg', 40, 1, -1)
	H.status_flags |= FAKEDEATH //we want to make sure they don't deathgasp and maybe possibly explode
	H.death()
	H.status_flags &= ~FAKEDEATH
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	user.visible_message("<span class='warning'>[user] presses [src] to [H]'s head, ripping through the skull and carefully extracting the brain!</span>", \
	"<span class='brass'>You extract [H]'s consciousness from [H.p_their()] body, trapping it in the soul vessel.</span>")
	transfer_personality(H)
	B.Remove(H)
	qdel(B)
	H.update_hair()
