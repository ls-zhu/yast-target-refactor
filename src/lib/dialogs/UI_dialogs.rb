# Simple example to demonstrate object API for CWM

# require_relative "example_helper"
require './src/lib/helps/example_helper.rb'
require './src/lib/TargetData.rb'
require 'cwm/widget'
require 'ui/service_status'
require 'yast'
require 'cwm/table'
require 'cwm/dialog'
require 'yast2/execute'

Yast.import 'CWM'
Yast.import 'CWMTab'
Yast.import 'TablePopup'
Yast.import 'CWMServiceStart'
Yast.import 'Popup'
Yast.import 'Wizard'
Yast.import 'CWMFirewallInterfaces'
Yast.import 'SuSEFirewall'
Yast.import 'Service'
Yast.import 'CWMServiceStart'
Yast.import 'UI'
Yast.import 'TablePopup'

class NoDiscoveryAuth_widget < ::CWM::CheckBox
  def initialize
    textdomain 'example'
  end

  def label
    _('No Discovery Authentication')
  end

  # auto called from Yast
  def init
    self.value = true # TODO: read config
  end

  def store
    puts "IT IS #{value}!!!"
  end

  def handle
    puts 'Changed!'
  end

  def opt
    [:notify]
  end
end

class BindAllIP < ::CWM::CheckBox
  def initialize
    textdomain 'example'
  end

  def label
    _('Bind all IP addresses')
  end

  # auto called from Yast
  def init
    self.value = true # TODO: read config
  end

  def store
    puts "IT IS #{value}!!!"
  end

  def handle
    puts 'Changed!'
  end

  def opt
    [:notify]
  end
end

class UseLoginAuth < ::CWM::CheckBox
  def initialize
    textdomain 'example'
  end

  def label
    _('Use Login Authentication')
  end

  # auto called from Yast
  def init
    self.value = true # TODO: read config
  end

  def store
    puts "IT IS #{value}!!!"
  end

  def handle
    puts 'Changed!'
  end

  def opt
    [:notify]
  end
end

class Auth_by_Initiators_widget < ::CWM::CheckBox
  def initialize
    textdomain 'example'
  end

  def label
    _("Authentication by initiators.\n")
  end

  # auto called from Yast
  def init
    self.value = true # TODO: read config
  end

  def store
    puts "IT IS #{value}!!!"
  end

  def handle
    puts 'Changed!'
  end

  def opt
    [:notify]
  end
end

class Auth_by_Targets_widget < ::CWM::CheckBox
  def initialize
    textdomain 'example'
  end

  def label
    _('Autnentication by Targets')
  end

  # auto called from Yast
  def init
    self.value = true # TODO: read config
  end

  def store
    puts "IT IS #{value}!!!"
  end

  def handle
    puts 'Changed!'
  end

  def opt
    [:notify]
  end
end

class UserName < CWM::InputField
  def initialize(str)
    @config = str
  end

  def label
    _('Username:')
  end

  def init
    self.value = @config
    printf("Username InputField init, got default value %s.\n", @config)
  end

  def store
    @config = value
    printf("Username Inputfield will store the value %s.\n", @config)
  end
end

class Password < CWM::InputField
  def initialize(str)
    @config = str
  end

  def label
    _('Password:')
  end

  def init
    self.value = @config
    printf("Password InputField init, got default value %s.\n", @config)
  end

  def store
    @config = value
    printf("Password Inputfield will store the value %s.\n", @config)
  end
end

class MutualUserName < CWM::InputField
  def initialize(str)
    @config = str
  end

  def label
    _('Mutual Username:')
  end

  def init
    self.value = @config
    printf("Mutual Username InputField init, got default value %s.\n", @config)
  end

  def store
    @config = value
    printf("Mutual Username Inputfield will store the value %s.\n", @config)
  end
end

class MutualPassword < CWM::InputField
  def initialize(str)
    @config = str
  end

  def label
    _('Mutual Password:')
  end

  def init
    self.value = @config
    printf("Mutual Password InputField init, got default value %s.\n", @config)
  end

  def store
    @config = value
    printf("Mutual Password Inputfield will store the value %s.\n", @config)
  end
end

module Yast
  class ServiceTab < ::CWM::Tab
    # @fire_wall_service = nil
    include Yast::I18n
    include Yast::UIShortcuts
    def initialize
      # Yast.import "SuSEFirewall"
      self.initial = true
      @service = Yast::SystemdService.find('targetcli')
      @service_status = ::UI::ServiceStatus.new(@service, reload_flag: true, reload_flag_label: :restart)
      # self.Read()
      # SuSEFirewall.Read()
    end

    def Read
      SuSEFirewall.Read()
    end

    def contents
      HBox(
        ::CWM::WrapperWidget.new(
          CWMFirewallInterfaces.CreateOpenFirewallWidget('services' => ['service:target']),
          id: 'firewall'
        ),
        @service_status.widget
      )
    end

    def label
      _('Service')
    end
  end
end
class GlobalTab < ::CWM::Tab
  def initialize
    self.initial = true
  end

  def contents
    VBox(
      # HStretch(),
      VStretch(),
      NoDiscoveryAuth_widget.new,
      Auth_by_Targets_widget.new,
      HBox(
        UserName.new('test username'),
        Password.new('test password')
      ),
      Auth_by_Initiators_widget.new,
      HBox(
        MutualUserName.new('test mutual username'),
        MutualPassword.new('test mutual password')
      )
    )
  end

  def label
    _('Global')
  end
end

class TargetsTab < ::CWM::Tab
  def initialize
    @target_table_widget = TargetsTableWidget.new
    # puts "Initialized a TargetsTab class."
    self.initial = false
  end

  def contents
    VBox(
      HStretch(),
      VStretch(),
      @target_table_widget
    )
  end

  def label
    _('Targets')
  end
end

class TargetNameInput < CWM::InputField
  def initialize(str)
    # printf("TargetName got default value %s.\n", str)
    @config = str.downcase
    # This line would lead a failure in y2log:
    # cwm/common_widgets.rb:37 UI::ChangeWidget failed: UI::ChangeWidget( `id ("TargetNameInput"), `Value, "iqn.2017-10.com.example" )
    # self.value = str
    @iscsi_name_length_max = 233
  end

  def label
    _('Target')
  end

  def validate
    puts 'Validate in TargetNameInput is called.'
    if value.empty?
      Yast::Popup.Error(_('Target name cannot be empty.'))
      return false
    elsif value.bytesize > @iscsi_name_length_max
      Yast::Popup.Error(_('Target name cannot be longger than 223 bytes.'))
      return false
    end
    printf("In TargetNameInput, value is %s.\n", value)
    true
  end

  def init
    self.value = @config.downcase
    # printf("TargeteName InputField init, got default value %s.\n",@config)
  end

  def store
    # puts "STORE is called."
    # printf("TargetName Inputfield will store the value %s.\n", @config)
    @config = value.downcase
    # pinttf("Value of TargetName is %s.\n",self.value)
  end

  def get_value
    # puts "get_value"
    # puts @config
    # puts value
    # puts self.value
    value.downcase
  end
end

class TargetIdentifierInput < CWM::InputField
  def initialize(str)
    @config = str.downcase
  end

  def label
    _('Identifier')
  end

  def validate
    self.value = @config.downcase
    # printf("In TargetIndentifierInput Validate, self.value is %s.\n", value)
    true
  end

  def init
    self.value = @config.downcase
    # printf("Target Identifier InputField init, got default value %s.\n",@config)
  end

  def store
    @config = value.downcase
    # printf("Target Identifier Inputfield will store the value %s.\n", @config)
  end

  def get_value
    value.downcase
  end
end

class PortalGroupInput < CWM::IntField
  def initialize(num)
    @config = num.to_i
    # p num.class
    # printf("@config is %d.\n", @config)
  end

  def label
    _('Portal Group')
  end

  def init
    self.value = @config
    # printf("Target Portal Group InputField init, got default value %s.\n",@config)
  end

  def store
    @config = value
    # printf("Target Portal Group will store the value %s.\n", @config)
  end

  def minimum
    0
  end
end

class TargetPortNumberInput < CWM::IntField
  def initialize(int)
    @config = int
  end

  def label
    _('Port Number')
  end

  def init
    self.value = @config
    # printf("Target port number InputField init, got default value %s.\n",@config)
  end

  def store
    @config = value
    # printf("Target port number will store the value %s.\n", @config)
  end

  def minimum
    0
  end
end

class IpSelectionComboBox < CWM::ComboBox
  def initialize
    @addrs = nil
    # @config = myconfig
  end

  def label
    _('IP Address:')
  end

  def init
    # self.value = @config.value
  end

  def store
    # @config.value = value
    # puts self.value
    # puts get_addr
  end

  def GetNetConfig
    ip_list = []
    re_ipv4 = Regexp.new(/[\d+\.]+\//)
    re_ipv6 = Regexp.new(/[\w+\:]+\//)
    ret = Yast::Execute.locally('ip', 'a', stdout: :capture)
    ip = ret.split("\n")
    ip.each do |line|
      line = line.strip
      if line.include?('inet') && !line.include?('deprecated') # don't show deprecated IPs
        if line.include?('inet6')
          ip_str = re_ipv6.match(line).to_s.delete!('/')
          if ip_str.start_with?('::1')
            next
          elsif ip_str.start_with?('fe80:')
            next
          else
            # p ip_str
            ip_list.push(ip_str)
          end
        else
          # delete "/", and drop 127.x.x.x locall address
          ip_str = re_ipv4.match(line).to_s.delete!('/')
          # p ip_str
          if ip_str.start_with?('127.')
            next
          else
            # p ip_str
            ip_list.push(ip_str)
          end
        end
      end
    end
    ip_list
  end

  def addresses
    # ["first", "second", "third","forth"]
    @addrs = self.GetNetConfig
    @addrs
  end

  def items
    result = []
    addresses.each_with_index do |a, i|
      result << [Id(i), a]
    end
    result
  end

  def get_addr
    # return addresses[self.value[0]]
    value
  end

  def opt
    [:notify]
  end
end

# This class is used for both adding a target and editing a target
class AddTargetWidget < CWM::CustomWidget
  include Yast
  include Yast::I18n
  include Yast::UIShortcuts
  include Yast::Logger

  # Fill nil when add a target or fill the name of the target to be edited
  def initialize(target_name)
    self.handle_all_events = true
    @iscsi_name_length_max = 223
    @back_storage = nil
    @target_name = nil
    # @target_info used to return target name, portal number, etc to upper level class.
    @target_info = []
    # luns contains the luns would be shown in the lun table
    luns = nil
    # if mode == "new", need to create targets and luns, if mode == "edit", just change the target config
    @mode = nil
    time = Time.new
    date_str = time.strftime('%Y-%m')
    if target_name.nil?
      @mode = 'new'
      @target_name_input_field = TargetNameInput.new('iqn.' + date_str + '.com.example')
      @target_identifier_input_field = TargetIdentifierInput.new(SecureRandom.hex(10))
      # @target_identifier_input_field = TargetIdentifierInput.new("123")
      @target_portal_group_field = PortalGroupInput.new(1)
      @target_port_num_field = TargetPortNumberInput.new(3260)
    else
      @mode = 'edit'
      printf("Editing target %s.\n", target_name)
      tpg_num = 0
      target_list = $target_data.get_target_list
      target = target_list.fetch_target(target_name)
      # tpg = target.fetch_tpg()
      tpg = target.get_default_tpg
      puts 'tpg is:'
      p tpg
      # we add a default target portal group = 1 if no tpgs exist.
      if tpg.nil?
        puts 'in if, tpg is'
        p tpg
        tpg_num = rand(10)
        puts tpg_num
        cmd = 'targetcli'
        p1 = 'iscsi/' + target_name + '/ create tag=' + tpg_num.to_s
        begin
          Cheetah.run(cmd, p1)
        rescue Cheetah::ExecutionFailed => e
          Yast::Popup.Error(e.stderr) unless e.stderr.nil?
        end
        $target_data.analyze
        target = target_list.fetch_target(target_name)
      end

      unless tpg.nil?
        puts 'in else,tpg is:'
        p tpg
        target = target_list.fetch_target(target_name)
        tpg_num = target.get_default_tpg.fetch_tpg_number
      end

      printf("tpg_num is %d.\n", tpg_num)
      luns = target.get_default_tpg.get_luns_array
      # p luns
      @target_name_input_field = TargetNameInput.new(target_name)
      # just use a empty string here to adapt the string parameter requirement
      @target_identifier_input_field = TargetIdentifierInput.new('')
      @target_portal_group_field = PortalGroupInput.new(tpg_num)
      @target_port_num_field = TargetPortNumberInput.new(3260)
    end

    @IP_selsection_box = IpSelectionComboBox.new
    @target_bind_all_ip_checkbox = BindAllIP.new
    @use_login_auth = UseLoginAuth.new
    @lun_table_widget = LUNsTableWidget.new(luns)
  end

  def contents
    VBox(
      HBox(
        @target_name_input_field,
        @target_identifier_input_field,
        @target_portal_group_field
      ),
      HBox(
        @IP_selsection_box,
        @target_port_num_field
      ),
      VBox(
        @target_bind_all_ip_checkbox,
        @use_login_auth
      ),
      @lun_table_widget
    )
  end

  def validate
    # puts 'validate in AddTarget Widget called.'
    if @mode == 'new'
      cmd = 'targetcli'
      p1 = 'iscsi/ create'
      if @target_name_input_field.get_value.bytesize > @iscsi_name_length_max
        @target_name = @target_name_input_field.get_value
      else
        @target_name = @target_name_input_field.get_value + ':' + @target_identifier_input_field.get_value
      end
      begin
        Cheetah.run(cmd, p1, @target_name)
      rescue Cheetah::ExecutionFailed => e
        unless e.stderr.nil?
          err_msg = _('Can not create the target with target name: ') + \
                    @target_name + _(", plese check target name.\n") + \
                    _('Additional information: ') + e.stderr
          Yast::Popup.Error(err_msg)
          return false
        end
      end
      target_tpg = @target_portal_group_field.value.to_s
      # Yast only support one TPG, targetcli will create a default tpg =1, if users provided another tpg number,
      # we need to delete tpg=1, then create another tpg based on the user provided number
      if target_tpg != '1'
        p1 = 'iscsi/' + @target_name + '/ delete tag=1'
        p2 = 'iscsi/' + @target_name + '/ create tag=' + target_tpg
        begin
          Cheetah.run(cmd, p1)
        rescue Cheetah::ExecutionFailed => e
          unless e.stderr.nil?
            err_msg = _('Target Portal Group number ') + target_tpg + _(' is provided to replace the defalult tpg') \
            + _('Failed to delete the default tpg, please consider to re-create the target and check') \
            + _('whether someone called targetcli manually')
            Yast::Popup.Error(err_msg)
            return false
          end
        end
        begin
          Cheetah.run(cmd, p2)
        rescue Cheetah::ExecutionFailed => e
          unless e.stderr.nil?
            err_msg = _('Failed to create Target Portal Group ') + target_tpg \
            + _('The target is create, in the meanwhile, please delete it if needed.') \
            + _('Or a defalut target portal group 1 will be added to the target when you edit it.')
            Yast::Popup.Error(err_msg)
            return false
          end
        end
      end
      @lun_table_widget.set_target_info(@target_name, target_tpg)
      return true
    end

    if @mode == 'edit'

    end
    true
  end

  # This function will create luns under tpg#N/luns from backstores
  # TODO: Add error handling here, exceptions!
  def create_luns
    # p "create_luns called."
    luns = @lun_table_widget.get_new_luns
    # p luns
    cmd = 'targetcli'
    p1 = 'iscsi/' + @target_name + '/tpg' + @target_portal_group_field.value.to_s + '/luns/' + ' create'
    luns.each do |lun|
      p2 = '/backstores/block/' + lun[3] if lun[4] == 'blockSpecial'
      p2 = '/backstores/fileio/' + lun[3] if lun[4] == 'file'
      # TODO: Add error handling here, exceptions!
      # TODO: Update Target table after add / remove targets
      ret = Yast::Execute.locally(cmd, p1, p2, stdout: :capture)
    end
  end

  def handle(event)
    # puts event
    case event['ID']
    when :next
      # puts "In next:"
      # puts @target_name_input_field.value
      # puts "clicked Next."
      # puts @target_name_input_field.value
      # self.prepare_luns_list
      # if @target_portal_group_field.value.to_s.empty?
      # self.popup_warning_dialog("Error", "Portal group can not be empty")
      # end
    end
    nil
  end
end

class TargetTable < CWM::Table
  def initialize
    # puts "initialize() is called."
    # functions like initialize and items would be called multiple times by its
    # container(and its container) working not properly
    # That's the reason why we need @items_need_refresh to control that. We should remove @items_need_refresh
    # when CWM work well. We don't need locks to protect it.
    # @items_need_refresh = false
    @targets = []
    @targets_names = $target_data.get_target_names_array
    @targets = generate_items
  end

  def init
    # puts 'init() is called.'
  end

  def generate_items
    # puts "generate_items() is called"
    items_array = []
    @targets_names.each do |elem|
      items_array.push([rand(9999), elem, 1, 'Enabled'])
    end
    p items_array
    items_array
  end

  def header
    [_('Targets'), _('Portal Group'), _('TPG Status')]
  end

  def items
    # puts "items() is called."
    # if @items_need_refresh = true
    # return generate_items()
    # else
    # return @targets
    # end
    @targets
  end

  def get_selected
    p @targets
    p value
    @targets.each do |target|
      p target
      return target if target[0] == value
    end
    nil
  end

  # this function will remove a target from the table.
  def remove_target_item(id)
    # p @targets
    @targets.each do |elem|
      # printf("id is %d.\n", id)
      if elem[0] == id
        # printf("elem[0] is %d.\n", elem[0]);
        # p elem
      end
      @targets.delete_if { |elem| elem[0] == id }
    end
    update_table
  end

  def update_table
    # puts "update_table() is called."
    $target_data.analyze
    @targets_names = $target_data.get_target_names_array
    change_items(generate_items)
  end
end

class TargetsTableWidget < CWM::CustomWidget
  include Yast
  include Yast::I18n
  include Yast::UIShortcuts
  include Yast::Logger
  def initialize
    # puts "Initialized a TargetsTableWidget class"
    # p caller
    self.handle_all_events = true
    @target_table = TargetTable.new
    # p "@target_table is"
    # p @target_table
    @add_target_page = nil
    @edit_target_page = nil
    # target_info will store target name, portal, etc
    @target_info = nil
  end

  def opt
    [:notify]
  end

  def contents
    VBox(
      Id(:targets_table),
      @target_table,
      HBox(
        PushButton(Id(:add), _('Add')),
        PushButton(Id(:edit), _('Edit')),
        PushButton(Id(:delete), _('Delete'))
      )
    )
  end

  def handle(event)
    # puts event
    # we put @target_table.update_table() in every case than outside the "case event", because handle would be called
    # in it's container, that will cause an unexpected update table.
    case event['ID']
    when :add
      @add_target_page = AddTargetWidget.new(nil)
      contents = VBox(@add_target_page, HStretch(), VStretch())
      Yast::Wizard.CreateDialog
      CWM.show(contents, caption: _('Add iSCSI Target'))
      Yast::Wizard.CloseDialog
      @target_table.update_table
    when :edit
      puts 'Clicked Edit button!'
      target = @target_table.get_selected
      p target
      unless target.nil?
        # p target
        @edit_target_page = AddTargetWidget.new(target[1])
        contents = VBox(@edit_target_page, HStretch(), VStretch())
        Yast::Wizard.CreateDialog
        CWM.show(contents, caption: _('Edit iSCSI Target'))
        Yast::Wizard.CloseDialog
      end
      @target_table.update_table
    when :delete
      id = @target_table.get_selected
      # puts "Clicked Delete button"
      printf("The selected value is %s.\n", id)
      # @target_table.remove_target_item(id)
      @target_table.update_table
    end
    nil
  end

  def help
    _('demo help')
  end
end

class LUNTable < CWM::Table
  def initialize(init_luns)
    # puts "initialize a LUNTable"
    # p caller
    # @luns will store all luns exsisted and will be created
    @luns = init_luns
    # @luns_add will store the luns will be created, will not store any exsisted luns.
    @luns_added = []
    @luns = generate_items
    @target_name = nil
    @target_tpg = nil
  end

  def set_target_info(name, tpg)
    @target_name = name
    @target_tpg = tpg
    # puts 'in set_target_name'
    # p @target_name
    # p @target_tpg
  end

  def generate_items
    # p "generate_items is called."
    items_array = []
    if !@luns.nil?
      return @luns
    else
      @luns = []
    end
    @luns
  end

  def header
    [_('LUN'), _('Name'), _('Path')]
  end

  def items
    @luns
  end

  def get_selected
    value
  end

  # This function will return the array @luns, LUNsTableWidget will use this to decide the lun number
  def get_luns
    @luns
  end

  # This function will return the array @luns_added, means the new luns need to create
  def get_new_luns
    @luns_added
  end

  # this function will add a lun in the table, the parameter item is an array
  def add_lun_item(item)
    @luns.push(item)
    @luns_added.push(item)
    update_table(@luns)
  end

  # this function will delete a LUN both in a target tpg#n/luns and /backstore/fileio or block via targetcli
  def delete_lun(lun_str); end

  # this function will remove a lun from the table, will try to delete it from @luns_added and @luns
  def table_remove_lun_item(id)
    @luns_added.delete_if { |item| item[0] == id }
    @luns.delete_if { |item| item[0] == id }
    update_table(@luns)
  end

  def validate
    puts 'validate() in LUN_table is called.'
    failed_storage = String.new
    p @luns_added
    #TODO: should check lun_name(if exist, we should create the backstore here first), check lun_num(should use if exist)
    @luns_added.each do |lun|
      cmd = 'targetcli'
      if lun[2].empty? == false
        case lun[4]
          when "file"
            p1 = 'backstores/fileio create name=' + lun[2] + ' file_or_dev=' + lun[3]
            p2 = 'iscsi/' + @target_name + '/tpg' + @target_tpg + "/luns/ create" + \
                 'storage_object=/backstores/block/' + lun[2]
          when "blockSpecial"
            p1 = 'backstores/blockSpecial create name=' + lun[2] + 'dev=' + lun[3]
            p2 = 'iscsi/' + @target_name + '/tpg' + @target_tpg + "/luns/ create" + \
                 'storage_object=/backstores/fileio/' + lun[2]
        end
        if lun[3] != "-1"
          p2 += ('lun=' + lun[3])
        end
      end
      #create a backstorage first
      begin
        Cheetah.run(cmd, p1)
      rescue Cheetah::ExecutionFailed => e
        if e.stderr != nil
          failed_storage += (lun[3] + "\n")
          next
        end
      end
      #create lun using the backstore above
      begin
        Cheetah.run(cmd, p2)
      rescue Cheetah::ExecutionFailed => e
        if e.stderr != nil
          failed_storage += (lun[3] + "\n")
          #Need to delete the backstore if failed to create the lun even very unlikely to happen.
          case lun[4]
            when "file"
              p1 = 'backstores/fileio delete' + lun[2]
            when "blockSpecial"
              p1 = 'backstores/blockSpecial delete' + lun[2]
          end
          #we don't care whether it would fail, no damages.
          Cheetah.run(cmd, p1)
          next
        end
      end
##################################################################################################
      begin
        Cheetah.run(cmd, p1)
      rescue Cheetah::ExecutionFailed => e
        if e.stderr != nil
          failed_storage += (lun[3] + "\n")
        end
      end
      if failed_storage.empty? == false
        err_msg = _("Failed to create LUNs with such backstores:\n") + failed_storage + \
                  _("Please check whether the backstore or LUN number is in use, name is valid.\n") + \
                  _("You can try to edit the target to add the LUNs again.")
        Yast::Popup.Error(err_msg)
      end
    end
    true
  end


  def update_table(luns)
    change_items(luns)
  end
end

class LunNumInput < CWM::IntField
  def initialize(num)
    @config = num
  end

  def label
    _("LUN Number(left '-1' here to auto generate)")
  end

  def init
    self.value = @config
  end

  def store
    @config = value
  end

  def minimum
    -1
  end

  def get_value
    value
  end
end

class LUNPathInput < CWM::InputField
  def initialize(str)
    @config = str
  end

  def label
    _('LUN Path')
  end

  def validate
    if value.empty?
      Yast::UI.SetFocus(Id(widget_id))
      Yast::Popup.Error(_('LUN path cannot be empty.'))
      false
    else
      true
    end
  end

  def init
    self.value = @config
  end

  def store
    @config = value
  end

  def get_value
    value
  end

  def set_value(path)
    self.value = path
  end
end

class LunNameInput < CWM::InputField
  def initialize(str)
    @config = str
  end

  def label
    _('LUN Name(auto generated when empty)')
  end

  def validate
    true
  end

  def init
    self.value = @config
  end

  def store
    @config = value
  end

  def get_value
    value
  end
end

# This widget contains Lun path input and lun path browsing
class LUNPathEdit < CWM::CustomWidget
  include Yast
  include Yast::I18n
  include Yast::UIShortcuts
  include Yast::Logger
  def initialize
    self.handle_all_events = true
    @path = nil
    @lun_path_input = LUNPathInput.new("")
  end

  def contents
    HBox(
      @lun_path_input,
      PushButton(Id(:browse), _('Browse'))
    )
  end

  def get_value
    @lun_path_input.value
  end

  def store; end

  def validate
    file = @lun_path_input.value.to_s
    if File.exist?(file) == false
      Yast::Popup.Error(_('The file does not exist!'))
      @lun_path_input.value = nil
      return false
    end
    file_type = File.ftype(file)
    if (file_type != 'blockSpecial') && (file_type != 'file')
      Yast::Popup.Error(_('Please provide a normal file or a block device.'))
      @lun_path_input.value = nil
      return false
    end
    true
  end

  def handle(event)
    case event['ID']
    when :browse
      file = UI.AskForExistingFile('/', '', _('Select a file or device'))
      unless file.nil?
        # @path = file
        # @lun_path_input.set_value(file)
        @lun_path_input.set_value(file)
      end
    when :ok

    end
  end

  def help; end
end

# This is a class to config LUN path, number and name, used in LUNDetailsWidget contents
class LUNConfig < CWM::CustomWidget
  def initialize
    @lun_num_input = LunNumInput.new(nil)
    @lun_path_edit = LUNPathEdit.new
    @lun_name_input = LunNameInput.new(nil)
    @lun_info = []
  end

  def contents
    VBox(
      @lun_num_input,
      @lun_path_edit,
      @lun_name_input,
      HBox(
        PushButton(Id(:cancel), _('Cancel')),
        PushButton(Id(:ok), _('OK'))
      )
    )
  end

  def store
    # puts "store is called."
  end

  def validate
    # puts "validate is called."
    # printf("lun num is %d.\n", @lun_num_input.get_value)
    # printf("lun name is %s.\n", @lun_name_input.get_value)
    # printf("lun path is %s.\n", @lun_path_edit.get_value)
    @lun_info.push(@lun_num_input.get_value)
    @lun_info.push(@lun_name_input.get_value)
    @lun_info.push(@lun_path_edit.get_value)

    # lun_number = rand(100)
    # lun path to lun name. Like /home/lszhu/target.raw ==> home_lszhu_target.raw
    # lun_name = file[1,file.length].gsub(/\//,"_")
    # @lun_table.add_lun_item([rand(9999), lun_number, lun_name, file, File.ftype(file)])
    true
  end

  def handle
    # puts "handle is called."
  end

  def get_lun_info
    @lun_info
  end

  def help; end
end

class LUNDetailsWidget < CWM::Dialog
  def initialize
    @lun_config = LUNConfig.new
  end

  def title
    'Test Dialog'
  end

  def wizard_create_dialog
    Yast::UI.OpenDialog(layout)
    yield
  ensure
    Yast::UI.CloseDialog()
  end

  def contents
    VBox(
      @lun_config
    )
  end

  def should_open_dialog?
    true
  end

  def layout
    VBox(
      HSpacing(50),
      Left(Heading(Id(:title), title)),
      VStretch(),
      VSpacing(1),
      MinSize(50, 18, ReplacePoint(Id(:contents), Empty())),
      VSpacing(1),
      VStretch()
    )
  end

  def run
    super
    @lun_config.get_lun_info
  end
end

class LUNsTableWidget < CWM::CustomWidget
  include Yast
  include Yast::I18n
  include Yast::UIShortcuts
  include Yast::Logger
  def initialize(luns)
    self.handle_all_events = true
    @lun_table = LUNTable.new(luns)
    @lun_details = LUNDetailsWidget.new
    @target_name = nil
  end

  def contents
    VBox(
      @lun_table,
      HBox(
        PushButton(Id(:add), _('Add')),
        PushButton(Id(:edit), _('Edit')),
        PushButton(Id(:delete), _('Delete'))
      )
    )
  end

  # This function pass target name from AddTargetWidget to lun table
  def set_target_info(name, tpg)
    @lun_table.set_target_info(name, tpg)
  end

  # This function will return new luns, aka the newly added luns which needed to be created in tpg#N/luns
  def get_new_luns
    @lun_table.get_new_luns
  end

  def create_luns_backstores
    @lun_table.create_luns_backstore
  end

  def opt
    [:notify]
  end

  def validate
    # puts "Validate() in LunsTableWidget called.\n"
    true
  end

  def handle(event)
    # puts event
    case event['ID']
    when :edit
      ret = @lun_details.run
      lun_number = ret[0]
      lun_name = ret[1]
      file = ret[2]
      if !file.nil? && (File.exist?(file) == true)
        @lun_table.add_lun_item([rand(9999), lun_number, lun_name, file, File.ftype(file)])
      end
      puts 'Got the lun info:'
      puts ret
    when :add
      file = UI.AskForExistingFile('/', '', _('Select a file or device'))
      unless file.nil?
        luns = @lun_table.get_luns
        lun_number = rand(100)
        # lun path to lun name. Like /home/lszhu/target.raw ==> home_lszhu_target.raw
        lun_name = file[1, file.length].gsub(/\//, '_')
        @lun_table.add_lun_item([rand(9999), lun_number, lun_name, file, File.ftype(file)])
      end
    end
    nil
  end

  def help
    _('demo help')
  end
end
