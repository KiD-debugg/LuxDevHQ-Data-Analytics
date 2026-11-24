def welcome_setup():
    name_owner = input("Enter your name: ").strip().title()
    name_company = input("Enter your kiosk's name: ").strip().title()
    
    print("="*30)
    print(f"Welcome to {name_company} Kiosk, run by {name_owner}.")
    print("="*30)
    
shop_owner1=welcome_setup()
print(shop_owner1)