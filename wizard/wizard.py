#!/usr/bin/env python

import pygtk
pygtk.require('2.0')
import gtk
from exp import new_dir
import random
from multiprocessing import Process

class Assistant:
    def __init__(self):     

        assistant = gtk.Assistant()
        assistant.connect("apply", self.button_pressed, "Apply")
        assistant.connect("cancel", self.button_pressed, "Cancel")
        
        """
        vbox = gtk.VBox()
        vbox.set_border_width(5)
        page = assistant.append_page(vbox)
        assistant.set_page_title(vbox, "Step 1: Let us Get you Set Up")
        assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_INTRO)
        label = gtk.Label("This is an example label within an Assistant. The Assistant is used to guide a user through configuration of an application.")
        label.set_line_wrap(True)
        vbox.pack_start(label, True, True, 0)
        assistant.set_page_complete(vbox, True)
        """

        vbox = gtk.VBox()
        vbox.set_border_width(5)
        assistant.append_page(vbox)
        assistant.set_page_title(vbox, "Init")
        assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_CONTENT)
        label = gtk.Label("Step 1: Please enter your email address and choose a password...")
        label.set_line_wrap(False)

        label0 = gtk.Label("Email: ")        
        entry = gtk.Entry()
        entry.set_max_length(50)
        entry.connect("activate", self.print_value,entry)
        #entry.set_text("hello")
        #entry.insert_text(" world", len(entry.get_text()))
        #entry.select_region(0, len(entry.get_text()))
        entry.show()
        label0.set_mnemonic_widget(entry)

        label1 = gtk.Label("Password: ")        
        passwd = gtk.Entry()
        passwd.set_max_length(50)
        passwd.connect("activate", self.print_value,passwd)
        #passwd.set_text("password")
        #passwd.select_region(0, len(passwd.get_text()))
        passwd.set_visibility(0)
        passwd.show()
        label1.set_mnemonic_widget(passwd)

        vbox.pack_start(label, True, True, 0)
        vbox.pack_start(label0, True, True, 0)
        vbox.pack_start(entry, True, True, 0)
        vbox.pack_start(label1, True, True, 0)
        vbox.pack_start(passwd, True, True, 0)

        assistant.set_page_complete(vbox,True)

        #vbox.pack_start(button, True, True, 0)

        vbox = gtk.VBox()
        vbox.set_border_width(5)
        assistant.append_page(vbox)
        assistant.set_page_title(vbox, "Sharing")
        #assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_CONFIRM)
        assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_CONTENT)
        label = gtk.Label("Please tell us how many people do you want to share this folder with..")
        label.set_line_wrap(False)

        label0 = gtk.Label("Number of People: ")        
        people = gtk.Entry()
        people.set_max_length(2)
        people.set_text("1")
        people.show()
        label0.set_mnemonic_widget(people)

        vbox.pack_start(label, True, True, 0)
        vbox.pack_start(label0, True, True, 0)
        vbox.pack_start(people, True, True, 0)
        
        assistant.set_page_complete(vbox, True)
        #assistant.set_forward_page_func(function, data)

        vbox = gtk.VBox()
        vbox.set_border_width(5)
        assistant.append_page(vbox)
        assistant.set_page_title(vbox, "Sharing")
        #assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_CONFIRM)
        assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_CONTENT)
        label = gtk.Label("Please Enter with whom you wish to share")
        label.set_line_wrap(False)

        label0 = gtk.Label("Email Address of Person: ")        
        friend = gtk.Entry()
        friend.set_max_length(100)
        friend.set_text("")
        friend.show()
        label0.set_mnemonic_widget(friend)

        vbox.pack_start(label, True, True, 0)
        vbox.pack_start(label0, True, True, 0)
        vbox.pack_start(friend, True, True, 0)
        
        assistant.set_page_complete(vbox, True)
        #assistant.set_forward_page_func(function, data)
        
        vbox = gtk.VBox()
        vbox.set_border_width(5)
        assistant.append_page(vbox)
        assistant.set_page_title(vbox, "The Finale")
        assistant.set_page_type(vbox, gtk.ASSISTANT_PAGE_CONFIRM)
        label = gtk.Label("Awesome ! We're all done ! ")
        label.set_line_wrap(False)
        vbox.pack_start(label, True, True, 0)
        assistant.set_page_complete(vbox, True)
        
       
        assistant.connect("apply", self.save_values,[entry,passwd,friend])

        assistant.show_all()

    def button_pressed(self, assistant, button):
        print "%s button pressed" % button
        gtk.main_quit()

    def print_value(self,assistant,entry):
        print entry.get_text()
        
    def save_values(self,assistant,ls):
        #new_dir()
        p = Process(target=new_dir, args=(ls[0].get_text(),ls[1].get_text(),ls[2].get_text(),random.randint(10000000,99999999)))
        p.daemon = True
        p.start()
        p.join()


    """
    def return_value(self,assistant,entry):
        return entry.get_text()

    def return_values(self,assistant,entrylist):
        for i in xrange(len(entrylist)):
            print entrylist[i]
            entrylist[i] = entrylist[i].get_text()
        return entrylist
    """
    
if __name__ == '__main__':
    Assistant()
    gtk.main()