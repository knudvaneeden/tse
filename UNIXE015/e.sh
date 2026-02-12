#!/bin/sh

# e.sh - remotely edit files on the unix filesystem with
# a copy of TSE running on a connected windows box.
#
# Version 0.1.2

WATCH_DIR=/data/autoedit
WATCH_FILE=editfile
FILENAME=$1

# For Debugging:
# echo WATCH_DIR   $WATCH_DIR
# echo WATCH_FILE  $WATCH_FILE
# echo FILENAME    $FILENAME

function ask_rdc {
    RDC_ANSWER=
    RDC_OK=0

    while [ "$RDC_OK" -eq "0" ]; do
        echo -n "Re-Edit, Delete, or Cancel? [R, D, C] "

        read RDC_ANSWER
        RDC_ANSWER=`echo $RDC_ANSWER | cut -c1 | tr a-z A-Z`
        RDC_OK=0

        case "$RDC_ANSWER" in
            R)
                RDC_OK=1
            ;;
            D)
                RDC_OK=1
            ;;
            C)
                RDC_OK=1
            ;;
            *)
                RDC_OK=0
                RDC_ANSWER=
            ;;
        esac
    done
}

function ask_yn {
    YN_ANSWER=
    YN_OK=0

    while [ "$YN_OK" -eq "0" ]; do
        echo -n "$YN_TEXT "

        read YN_ANSWER
        YN_ANSWER=`echo $YN_ANSWER | cut -c1 | tr a-z A-Z`
        YN_OK=0

        case "$YN_ANSWER" in
            Y)
                YN_OK=1
            ;;
            N)
                YN_OK=1
            ;;
            *)
                YN_OK=0
                YN_ANSWER=
            ;;
        esac
    done
}


if [ "$FILENAME" == "" ]; then
    echo Usage: e filename
    exit 255
fi

BASENAME=`basename $FILENAME`

# For debugging:
# echo BASENAME    $BASENAME

if [ -e $FILENAME ]; then

    if [ -e $WATCH_DIR/$BASENAME ]; then
        echo
        echo The file "$WATCH_DIR/$BASENAME" already exists!
        echo You can:
        echo " * Re-Edit this file (this assumes the copy in TSE is latest)"
        echo " * Delete this file  (this assumes the copy in Unix Filesystem is latest)"
        echo " * Cancel "
        echo
        ask_rdc
        case "$RDC_ANSWER" in

            # User canceled.  We're outtahere
            C)
                echo Cancelled...
                exit 255
            ;;

            # Delete the editor file and overwrite with the
            # actual unix file
            D)
                echo First make sure that file is not still in the TSE ring!
                echo Press ENTER when you have confirmed this.

                read pause

                rm -f $WATCH_DIR/$BASENAME
                if ! cp $FILENAME $WATCH_DIR ; then
                    echo Could not copy $FILENAME to $WATCH_DIR!
                    exit 255
                fi
            ;;

            # If the user wants to Re-Edit, it's simple: we do nothing
        esac

    else
        echo copying $FILENAME to $WATCH_DIR!
        if ! cp $FILENAME $WATCH_DIR ; then
            echo Could not copy $FILENAME to $WATCH_DIR!
            exit 255
        fi
    fi
fi

touch $WATCH_DIR/$BASENAME
rm -f $WATCH_DIR/$BASENAME.saved

# echo "Contents of edited file $WATCH_DIR/$BASENAME (before edit):"
# cat $WATCH_DIR/$BASENAME
# echo --end of file--

echo $BASENAME > $WATCH_DIR/$WATCH_FILE

echo Editing $FILENAME via $WATCH_DIR/$BASENAME ...

until [ -e $WATCH_DIR/$BASENAME.saved ];
    do echo -n
done

echo File saved!

if cp -f $WATCH_DIR/$BASENAME $FILENAME ; then
    # echo "Contents of edited file $WATCH_DIR/$BASENAME (after edit):"
    # cat $WATCH_DIR/$BASENAME
    # echo --end of file--
    mv -f $WATCH_DIR/$BASENAME $WATCH_DIR/$BASENAME.old
    rm -f $WATCH_DIR/$BASENAME.saved

else
    echo Could not overwrite original file!
    YN_TEXT="Try using sudo? (Y/N)"
    ask_yn
    case "$YN_ANSWER" in

        # Attempt same operation with sudo
        Y)
            if sudo cp -f $WATCH_DIR/$BASENAME $FILENAME ; then
                mv -f $WATCH_DIR/$BASENAME $WATCH_DIR/$BASENAME.old
                rm -f $WATCH_DIR/$BASENAME.saved
            fi
        ;;

        # Don't try operation.  Still rename to filename.old
        N)
            mv -f $WATCH_DIR/$BASENAME $WATCH_DIR/$BASENAME.old
            rm -f $WATCH_DIR/$BASENAME.saved
            echo Original File is now in $WATCH_DIR/$BASENAME.old
            exit 255
        ;;

    esac

fi
