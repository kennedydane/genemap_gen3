from django.contrib.postgres.fields import HStoreField
from django.db import models
from django.utils.translation import gettext_lazy as _

# Create your models here.


class Gen3Group(models.Model):
    name = models.CharField(max_length=255, primary_key=True)
    policies = models.ManyToManyField('Gen3Policy')
    users = models.ManyToManyField('Gen3User')

    class Meta:
        ordering = ['name']


class Gen3Resource(models.Model):
    name = models.CharField(max_length=255, primary_key=True)
    parent_resource = models.ForeignKey('self', on_delete=models.CASCADE, blank=True, null=True)

    def __str__(self):
        if self.parent_resource:
            return f'{self.parent_resource}/{self.name}'
        return f'/{self.name}'

    class Meta:
        ordering = ['name']


class Gen3Policy(models.Model):
    id = models.CharField(max_length=255, primary_key=True)
    description = models.CharField(max_length=255, blank=True)
    roles = models.ManyToManyField('Gen3Role', blank=True)
    resources = models.ManyToManyField('Gen3Resource', blank=True)
    is_anonymous_policy = models.BooleanField(default=False)
    is_all_users_policy = models.BooleanField(default=False)

    def __str__(self):
        return self.id

    class Meta:
        verbose_name_plural = 'Gen3 policies'
        ordering = ['id']


class Gen3Role(models.Model):
    id = models.CharField(max_length=255, primary_key=True)
    description = models.CharField(max_length=255, blank=True)
    permissions = models.ManyToManyField('Gen3Permission')

    def __str__(self):
        return f'{self.id}: {"; ".join(str(permission) for permission in self.permissions.all())}'

    class Meta:
        ordering = ['id']


class Gen3Permission(models.Model):
    id = models.CharField(max_length=255, primary_key=True)
    action = models.ForeignKey('Gen3Action', on_delete=models.CASCADE)

    def __str__(self):
        return f'{self.id} : {self.action}'

    class Meta:
        ordering = ['id']


class Gen3Action(models.Model):
    class Methods(models.TextChoices):
        ACCESS = 'AC', _('access')
        ALL = 'AL', _('*')
        CREATE = 'CR', _('create')
        DELETE = 'DL', _('delete')
        FILE_UPLOAD = 'FU', _('file_upload')
        READ = 'RD', _('read')
        READ_STORAGE = 'RS', _('read-storage')
        UPDATE = 'UP', _('update')
        WRITE_STORAGE = 'WS', _('write-storage')

    service = models.ForeignKey('Gen3Resource', on_delete=models.CASCADE)
    action = models.CharField(max_length=2, choices=Methods.choices, default=Methods.ALL)

    def __str__(self):
        return f'{self.service} ({self.get_action_display()})'

    class Meta:
        ordering = ['service', 'action']


class Gen3Client(models.Model):
    pass


class Gen3User(models.Model):
    name = models.CharField(max_length=255, primary_key=True)
    policies = models.ManyToManyField('Gen3Policy')
    tags = HStoreField()

    class Meta:
        ordering = ['name']


class Gen3Program(models.Model):
    projects = models.ManyToManyField('Gen3Project')


class Gen3Project(models.Model):
    pass
