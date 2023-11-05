#!/bin/bash

get_movie_data() {
	echo -n "Please enter 'movie id'(1~1682):"
	read movie_id
	echo ""
	grep "^$movie_id|" u.item
}

get_action_genre(){
	echo -n "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):"
	read yn
	if [ "$yn" = "y" ]
	then
		awk -F\| '$7 == 1 {print $1, $2}' u.item | head -n 10
	fi
}

get_average_rating(){
	echo -n "Please enter the 'movie id'(1~1682):"
	read movie_id
	echo ""
	echo -n "average rating of $movie_id: "
	awk -v mv_id="$movie_id" '$2 == mv_id {sum += $3; count++} END {printf "%.5f", sum/count}' u.data
}

delete_url(){
	sed 's/http:\/\/[^|]*|/|/g' u.item | head -n 10
}

get_user_data(){
	echo -n "Do you want to get the data about users from 'u.user'?(y/n):"
	read yn
	echo ""
	if [ "$yn" = "y" ]
	then
		sed -E 's/([0-9]+)\|([0-9]+)\|M\|([^\|]*)\|(.*$)/user \1 is \2 years old male \3/; s/([0-9]+)\|([0-9]+)\|F\|([^\|]*)\|(.*$)/user \1 is \2 years old female \3/' u.user | head -n 10
	fi
}

modify_date(){
	echo -n "Do you want to Modify the format of 'release date' in 'u.item'?(y/n):"
	read yn
	echo ""
	if [ "$yn" = "y" ]
	then
		sed -E -e 's/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/; s/Sep/09/; s/Oct/10/; s/Nov/11/; s/Dec/12/' -E -e 's/([0-9]+)\|([^|]*)\|([^-]*)-([^-]*)-([0-9]+)\|(.*$)/\1\|\2\|\5\4\3\|\6/' u.item | tail -n 10
	fi
}

user_rate(){
	echo -n "Please enter the 'user id' (1~943):"
	read user_id
	echo ""
	movie_id=$(awk -v u_id="$user_id" '$1 == u_id {print $2}' u.data | sort -n | tr '\n' '|')
	echo $movie_id
	echo ""
	movie_id=$(echo "$movie_id" | tr '|' '\n' | head -n 10)
	for id in $movie_id
	do
		m_title=$(awk -F '|' -v m_id="$id" '$1 == m_id {print $2}' u.item)
		echo "$id|$m_title"
	done
}

special_rate(){
	echo -n "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):"
	read yn
	if [ "$yn" = "y" ]
	then
		prgs=$(awk -F '|' '$2>=20 && $2<=29 && $4=="programmer"{print $1}' u.user)
		prgs_data=""
		for i in $prgs
		do
			prgs_data+="$(awk -F ' ' -v prg="$i" '$1==prg {printf("%d %d\n",$2,$3)}' u.data)"
		done
		rating_data=""
		for i in $(seq 1682)
		do
			sum=0
			count=0
			prgs_data_i=$(awk -F ' ' -v i="$i" '$1==i {printf("%d %d\n",$1,$2)}')
			while read line
			do
				rating=$(echo "$line" | awk -F ' ' '{print $2}')
				sum=$((sum+rating))
				count=$((count+1))
				echo "success $i-$count"
				#mv_id=$(echo "$line" | awk -F ' ' '{print $1}')
				#mv_id=$((mv_id))
				#if [ "$mv_id" -eq "$i" ]
				#then
					#rating=$(echo "$line" | awk -F ' ' '{print $2}')
					#sum=$((sum+rating))
					#count=$((count+1))
					#echo "->mv_id=$mv_id, i=$i, rating= $rating, sum= $sum, count= $count"
				#fi
			done <<< "$prgs_data_i"
			if [ "$count" -gt 0 ]
			then
				average=$(awk -v sum=$sum -v count=$count '{printf "%.5f", sum/count}')
				rating_data+="$i $average\n"
			fi
		done
		echo -e "$rating_data"
	fi
}

echo "--------------------------"
echo "User Name: 이명진"
echo "Student Number: 12224425"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true
do
	echo -n "Enter your choice [ 1-9 ] "
	read choice
	echo ""

	case $choice in
	1)
		get_movie_data
		echo ""
		;;
	2)
		get_action_genre
		echo ""
		;;
	3)
		get_average_rating
		echo ""
		;;
	4)
		delete_url
		echo ""
		;;
	5)
		get_user_data
		echo ""
		;;
	6)
		modify_date
		echo ""
		;;
	7)
		user_rate
		echo ""
		;;
	8)
		special_rate
		echo ""
		;;
 	9)
		echo "Bye!"
		exit
		;;
	esac

done

