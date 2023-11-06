from django.contrib import admin

from .models import Gen3User, Gen3Group, Gen3Policy, Gen3Resource, Gen3Role, Gen3Permission, Gen3Action

# Register your models here.

@admin.register(Gen3User)
class Gen3UserAdmin(admin.ModelAdmin):
    pass


@admin.register(Gen3Group)
class Gen3GroupAdmin(admin.ModelAdmin):
    pass


@admin.register(Gen3Policy)
class Gen3PolicyAdmin(admin.ModelAdmin):
    pass


@admin.register(Gen3Resource)
class Gen3ResourceAdmin(admin.ModelAdmin):
    pass


@admin.register(Gen3Role)
class Gen3RoleAdmin(admin.ModelAdmin):
    filter_horizontal = ('permissions',)


@admin.register(Gen3Permission)
class Gen3PermissionAdmin(admin.ModelAdmin):
    pass


@admin.register(Gen3Action)
class Gen3ActionAdmin(admin.ModelAdmin):
    pass

